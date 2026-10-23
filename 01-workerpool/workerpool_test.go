package workerpool

import (
	"context"
	"errors"
	"fmt"
	"runtime"
	"sync/atomic"
	"testing"
	"time"
)

func makeJobs(n int) []Job {
	jobs := make([]Job, n)
	for i := range jobs {
		jobs[i] = Job{Index: i, Payload: fmt.Sprintf("vm-%03d", i)}
	}
	return jobs
}

func echo(_ context.Context, j Job) (Result, error) {
	// Later jobs finish first, so ordering bugs show up.
	time.Sleep(time.Duration(20-j.Index%20) * time.Millisecond)
	return Result{Index: j.Index, Output: "booted " + j.Payload}, nil
}

func TestNoWorkers(t *testing.T) {
	_, err := Run(context.Background(), 0, makeJobs(3), echo)
	if !errors.Is(err, ErrNoWorkers) {
		t.Fatalf("want ErrNoWorkers, got %v", err)
	}
}

func TestEmptyJobs(t *testing.T) {
	res, err := Run(context.Background(), 4, nil, echo)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if res == nil || len(res) != 0 {
		t.Fatalf("want empty non-nil slice, got %#v", res)
	}
}

func TestOrderPreserved(t *testing.T) {
	jobs := makeJobs(50)
	res, err := Run(context.Background(), 8, jobs, echo)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if len(res) != len(jobs) {
		t.Fatalf("want %d results, got %d", len(jobs), len(res))
	}
	for i, r := range res {
		if r.Index != i || r.Output != "booted "+jobs[i].Payload {
			t.Fatalf("results[%d] = %+v, want the result for jobs[%d]", i, r, i)
		}
	}
}

func TestBoundedConcurrency(t *testing.T) {
	const workers = 3
	var active, peak int32
	fn := func(_ context.Context, j Job) (Result, error) {
		n := atomic.AddInt32(&active, 1)
		for {
			p := atomic.LoadInt32(&peak)
			if n <= p || atomic.CompareAndSwapInt32(&peak, p, n) {
				break
			}
		}
		time.Sleep(5 * time.Millisecond)
		atomic.AddInt32(&active, -1)
		return Result{Index: j.Index}, nil
	}
	if _, err := Run(context.Background(), workers, makeJobs(40), fn); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if peak > workers {
		t.Fatalf("saw %d concurrent calls, limit is %d", peak, workers)
	}
	if peak < 2 {
		t.Fatalf("saw at most %d concurrent call(s); the pool is not running work in parallel", peak)
	}
}

func TestFirstErrorCancelsTheRest(t *testing.T) {
	boom := errors.New("disk image checksum mismatch")
	var started int32
	fn := func(ctx context.Context, j Job) (Result, error) {
		atomic.AddInt32(&started, 1)
		if j.Index == 2 {
			return Result{}, boom
		}
		select {
		case <-ctx.Done():
			return Result{}, ctx.Err()
		case <-time.After(2 * time.Second):
			return Result{Index: j.Index}, nil
		}
	}
	start := time.Now()
	_, err := Run(context.Background(), 4, makeJobs(100), fn)
	if !errors.Is(err, boom) {
		t.Fatalf("want the first error (%v), got %v", boom, err)
	}
	if d := time.Since(start); d > time.Second {
		t.Fatalf("Run took %v; the other calls were not cancelled", d)
	}
	if s := atomic.LoadInt32(&started); s > 20 {
		t.Fatalf("%d jobs started after the failure; stop handing out new jobs once one fails", s)
	}
}

func TestParentContextCancel(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
	defer cancel()
	slow := func(ctx context.Context, j Job) (Result, error) {
		select {
		case <-ctx.Done():
			return Result{}, ctx.Err()
		case <-time.After(5 * time.Second):
			return Result{Index: j.Index}, nil
		}
	}
	start := time.Now()
	_, err := Run(ctx, 2, makeJobs(10), slow)
	if !errors.Is(err, context.DeadlineExceeded) {
		t.Fatalf("want context.DeadlineExceeded, got %v", err)
	}
	if d := time.Since(start); d > time.Second {
		t.Fatalf("Run took %v after the context expired", d)
	}
}

func TestNoGoroutineLeak(t *testing.T) {
	before := runtime.NumGoroutine()
	for i := 0; i < 20; i++ {
		_, _ = Run(context.Background(), 5, makeJobs(30), func(_ context.Context, j Job) (Result, error) {
			if j.Index == 7 {
				return Result{}, errors.New("fail")
			}
			return Result{Index: j.Index}, nil
		})
	}
	deadline := time.Now().Add(time.Second)
	for runtime.NumGoroutine() > before+2 && time.Now().Before(deadline) {
		time.Sleep(10 * time.Millisecond)
	}
	if after := runtime.NumGoroutine(); after > before+2 {
		t.Fatalf("goroutines: %d before, %d after; something is still blocked", before, after)
	}
}
