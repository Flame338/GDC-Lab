// Package workerpool is exercise 1 of the GDC lab (Linear PSE-210).
//
// Implement Run so that every test in workerpool_test.go passes, including
// under the race detector:
//
//	go test -race ./01-workerpool/...
//
// Rules for yourself: no copying a solution. Write it the way you would on a
// shared doc in an interview, then run the tests. When a test fails, read the
// test before you read the code.
package workerpool

import (
	"context"
	"errors"
)

// Job is one unit of work. Index is its position in the input slice.
type Job struct {
	Index   int
	Payload string
}

// Result is what a worker produced for one job.
type Result struct {
	Index  int
	Output string
}

// ErrNoWorkers is returned when workers < 1.
var ErrNoWorkers = errors.New("workerpool: need at least one worker")

// Run processes jobs with at most `workers` goroutines running fn at once.
//
// Requirements (each one has a test):
//  1. Returns ErrNoWorkers if workers < 1.
//  2. Returns one Result per job, in the same order as jobs (results[i]
//     belongs to jobs[i]), even though jobs finish out of order.
//  3. Never runs more than `workers` calls of fn at the same time.
//  4. If any fn returns an error, Run returns that first error, cancels the
//     context passed to the other calls, and does not start new jobs.
//  5. If ctx is cancelled, Run stops promptly and returns ctx.Err().
//  6. Leaks no goroutines: every goroutine it starts has exited by the time
//     Run returns.
//  7. An empty jobs slice returns an empty (non-nil) slice and no error.
//
// Hints, if you are stuck for 25 minutes: a jobs channel, a WaitGroup,
// context.WithCancel, and a sync.Once (or errgroup-style pattern) for the
// first error. Results can go straight into a pre-sized slice by index.
func Run(ctx context.Context, workers int, jobs []Job, fn func(context.Context, Job) (Result, error)) ([]Result, error) {
	// TODO(PSE-210): implement.
	return nil, errors.New("not implemented")
}
