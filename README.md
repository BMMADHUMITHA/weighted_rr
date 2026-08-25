# weighted_rr
The weight of each master is defined as the grant time slice that the master can configure in the arbiter. If all the masters have the same amount of weight, each master will get an equal time. If master A requests 20 cycles and master B requests 10 cycles, master A will get grant 2 times longer than master B. One disadvantage of letting the masters configure the weight is that a master may configure a very large weight. To reduce this large weight problem, another global configurable maximum allowed weight is added. A master may request a very large weight value, but the arbiter will only grant up to the maximum allowed
weight if there are other masters waiting.

# weight decoder
Weight decoder decodes one-hot grant to decode the correct weight of the granted master. Weight of the masters are concatenated to form a weight bus, the width of the bus can be calculated by the width of a single weight and the total number of masters in the arbiter. Weight decoder takes the current grant as an one-hot input. The input grant is decoded to produce an index for correct bit slice positions of the weight bus. For example, if the grant is b ′0010, the index output is 1. Index of 1 stands for the master no. 1. The weight of master 1 is decoded as an output. If the grant is b ′0100, index output is 2. The weight of master 2 is decoded as an output.

<img width="132" alt="image" src="https://github.com/BMMADHUMITHA/weighted_rr/assets/134037700/cf43c9fe-b31c-4807-8434-17c879566bbe">

# Next Grant Precalculator
Next Grant PReCalculator(NGPRC) calculates the next possible grants mask based on the current grant. By precalculating the next possible grants, NGPRC dictates the Round Robin arbitration of the arbiter. For example, if all 4 masters in the arbiter are requesting and the current grant is master 1, the next possible grant is restricted to be in the order of master 2, master 3 and master 0. The arbiter cannot skip master 2 to grant master 3. It would violate the Round-robin scheme and it is not allowed. By giving the next possible grant priority to the Grant State-machine, it forces the grant to be in strict Round-robin order. . For example, if the current grant is b′0010, rotate left gives b ′0100. After inversion, the bits become b ′1011. After increment by 1, the next possible grant becomes b ′1100. It means the leftmost 2 bits are in line in priority.

# Grant State Machine
Grant state machine is the logic to calculate which master gets the grant and for how long based on the weight. The grant logic is based on the requests and next grant priority mask created by NGPRC. “Grant Process” state masks requests using a precalculated mask to grant the next requesting master. After the grant is decided, it moves to the “Get Weight” state to fetch the weight of the grant from Weight Decoder. After that, it moves to the “Count” state to count the clock cycles until the local counter reaches the desired weight.

<img width="347" alt="image" src="https://github.com/BMMADHUMITHA/weighted_rr/assets/134037700/11aa54b9-16f0-4aea-b54c-0f608ed4566b">

# Output
<img width="454" alt="image" src="https://github.com/BMMADHUMITHA/weighted_rr/assets/134037700/ad2f16fc-ab61-4563-8d7e-9e4ada4b05b9">

<img width="455" alt="image" src="https://github.com/BMMADHUMITHA/weighted_rr/assets/134037700/5f19ab18-81a5-4dea-a125-c83a00f39ff9">

# Coverage:

<img width="685" alt="image" src="https://github.com/BMMADHUMITHA/weighted_rr/assets/134037700/68ff1f33-8896-4809-8563-73835ce91a36">

# Prepared by:
B M Madhumitha


# References

Toe, Aung, "Design and Verification of a Round-Robin Arbiter" (2018). Thesis. Rochester Institute of Technology

# Washing Machine Simulator 

**Name:** B M Madhumitha **Course:** PhD ESE **SR No.:**
04-01-00-10-12-26-01-28178

> **Project documentation** 

**\## 1. Overview**

This project is a console-based washing machine simulator written in C.

The main machine behavior is controlled by three modified implementation

files:

-   `machine.c` --- machine state, mode selection, start/abort, door,

    and detergent logic

-   `timer.c` --- wash durations, countdown, completion, and timer

    thread

-   `power.c` --- power-off/failure handling and power restoration

The supporting files (`main.c`, `input.c/.h`, `display.c/.h`, and the

corresponding headers) provide the menu, input mapping, status display,

and declarations.

The simulator uses \*\*\*\*one real second as one simulated
minute\*\*\*\*.

\*\*## 2. Machine State Model

`WashingMachine` stores the following important values:

  -----------------------------------------------------------------------
  Variable                            Purpose
  ----------------------------------- -----------------------------------
  `mode`                              Selected wash mode

  `state`                             Current machine state

  `door_status`                       Door state: open, closed, or locked

  `remaining_time`                    Remaining simulated minutes

  `detergent_present`                 Whether detergent has been filled

  `start_requested`                   Whether Start was requested but is
                                      waiting for detergent/door
                                      conditions

  `timer_running`                     Whether the countdown is active

  `power_present`                     Whether power is available

  `simulator_running`                 Controls the timer thread

  `mutex`                             Protects shared machine state
                                      between the main thread and timer
                                      thread
  -----------------------------------------------------------------------

### Wash modes

  Mode         Duration
  -------- ------------
  Heavy      45 minutes
  Normal     30 minutes
  Light      20 minutes

### States

The code defines these states:

-   `IDLE`
-   `WAITING_FOR_DETERGENT`
-   `RUNNING`
-   `POWER_FAILURE`
-   `COMPLETED`
-   `ABORTED`

`COMPLETED` and `ABORTED` are short-lived transitional states: the code
immediately resets the machine to `IDLE`.

## 3. Initial Startup\*\*

`machine\_init()` performs the initial setup:

1\. Initializes the mutex.

2\. Sets `power\_present = 1`.

3\. Sets `simulator\_running = 1`.

4\. Calls `reset\_to\_idle()`.

After initialization:

``` text

Power          = ON

Mode           = NONE

State          = IDLE

Door           = OPEN

Remaining Time = 0

Detergent      = EMPTY

Start Request  = NONE

Timer Running  = NO
```

The timer thread is then created by `main.c`.

``` mermaid

flowchart TD

    A[Program starts] -→ B[machine\_init]

    B -→ C[Power ON]

    C -→ D[Reset machine to IDLE]

    D -→ E[Start timer thread]

    E -→ F[Display menu]
```

**\## 4. Selecting a Wash Mode**

The user can select:

-   Heavy → 45 minutes

-   Normal → 30 minutes

-   Light → 20 minutes

Before changing the mode, `machine\_select\_mode()` checks:

1\. Is power ON?

2\. Is the machine in `POWER\_FAILURE`?

3\. Is the mode valid?

4\. Is a wash cycle already `RUNNING`?

5\. Is a Start request already waiting for detergent?

If any required condition fails, the mode is not changed.

A mode can therefore be selected while the machine is idle, before

starting a cycle.

``` mermaid

flowchart TD

    A[Select mode] -→ B{Power ON?}

    B -- No -→ X[Reject]

    B -- Yes -→ C{POWER\_FAILURE?}

    C -- Yes -→ X

    C -- No -→ D{Valid mode?}

    D -- No -→ X

    D -- Yes -→ E{RUNNING?}

    E -- Yes -→ X

    E -- No -→ F{WAITING\_FOR\_DETERGENT?}

    F -- Yes -→ X

    F -- No -→ G[Store selected mode]
```

**\## 5. Starting a Wash Cycle**

The Start operation is handled by `machine\_start()` and then

`machine\_start\_locked()`.

**\### Start checks**

The machine must have:

-   Power ON

-   A valid wash mode

-   Door CLOSED

-   Detergent PRESENT

If all four conditions are satisfied:

``` text

remaining\_time = selected mode duration

door\_status    = DOOR\_LOCKED

state          = RUNNING

timer\_running  = 1

start\_requested = 0
```

**\### Important: Start before detergent**

If Start is pressed without detergent:

``` text

start\_requested = 1

state            = WAITING\_FOR\_DETERGENT

timer\_running    = 0
```

The machine does \*\*\*\*not\*\*\*\* begin counting down.

The pending request is later checked when detergent is filled or when

the door is closed.

``` mermaid

flowchart TD

    A[Press Start] -→ B{Power ON?}

    B -- No -→ X[Reject]

    B -- Yes -→ C{Valid mode selected?}

    C -- No -→ X

    C -- Yes -→ D{Door closed?}

    D -- No -→ X

    D -- Yes -→ E{Detergent present?}

    E -- No -→ F[Set start\_requested = 1]

    F -→ G[State = WAITING\_FOR\_DETERGENT]

    G -→ H[Timer stopped]

    E -- Yes -→ I[Load mode duration]

    I -→ J[Lock door]

    J -→ K[State = RUNNING]

    K -→ L[Start timer]
```

**\## 6. Door Behavior**

**\### Opening the door**

`machine\_open\_door()` rejects the operation when:

-   Power is OFF

-   State is `POWER\_FAILURE`

-   Door is already locked

A locked door therefore cannot be opened while the wash cycle is

running.

If the door is closed and the machine is otherwise allowed to open it:

``` text

door\_status = DOOR\_OPEN
```

**\### Closing the door**

`machine\_close\_door()` rejects the operation when:

-   Power is OFF

-   State is `POWER\_FAILURE`

-   Door is already closed

-   Door is already locked

After closing the door:

``` text

door\_status = DOOR\_CLOSED
```

There is an important automatic-start path:

If:

``` text

state == WAITING\_FOR\_DETERGENT

start\_requested == 1

detergent\_present == 1

power\_present == 1
```

then closing the door calls `machine\_start\_locked()` and the wash
starts

immediately.

``` mermaid

flowchart TD

    A[Close door] -→ B{Waiting for detergent?}

    B -- No -→ C[Door becomes CLOSED]

    B -- Yes -→ D{Start pending + detergent present + power ON?}

    D -- No -→ C

    D -- Yes -→ E[Start wash automatically]

    E -→ F[Door LOCKED]

    F -→ G[State RUNNING]
```

**\## 7. Detergent Behavior**

`machine\_fill\_detergent()` first checks that power is available and
that

the machine is not in `POWER\_FAILURE`.

If detergent is already present, the operation is rejected.

Otherwise:

``` text

detergent\_present = 1
```

**\### If Start is already pending**

There are two paths.

**\#### Door is open**

The machine remains:

``` text

WAITING\_FOR\_DETERGENT

start\_requested = 1

detergent\_present = 1

door\_status = OPEN
```

The user is told to close the door.

**\#### Door is closed**

If Start is pending and the door is already closed,

`machine\_start\_locked()` is called immediately.

``` mermaid

flowchart TD

    A[Fill detergent] -→ B{Power ON?}

    B -- No -→ X[Reject]

    B -- Yes -→ C{POWER\_FAILURE?}

    C -- Yes -→ X

    C -- No -→ D{Already filled?}

    D -- Yes -→ X

    D -- No -→ E[detergent\_present = 1]

    E -→ F{Start pending?}

    F -- No -→ G[Remain in current state]

    F -- Yes -→ H{Door open?}

    H -- Yes -→ I[Wait for door to close]

    H -- No -→ J[Start wash]
```

**\## 8. Timer Thread**

The timer is implemented as a separate pthread.

`timer\_thread()` repeatedly:

1\. Sleeps for 1 real second.

2\. Checks `simulator\_running`.

3\. Calls `timer\_tick()`.

Therefore:

``` text

1 real second = 1 simulated minute
```

`timer\_tick()` only decrements the timer when:

``` text

state == RUNNING

timer\_running == 1

power\_present == 1
```

When these conditions are false, the tick is ignored.

**\### Countdown**

Every valid timer tick:

``` text

remaining\_time--
```

When `remaining\_time` reaches zero, the wash completes.

``` mermaid

flowchart TD

    A[Timer thread] -→ B[Sleep 1 second]

    B -→ C{Simulator running?}

    C -- No -→ Z[Exit timer thread]

    C -- Yes -→ D[timer\_tick]

    D -→ E{RUNNING + timer active + power ON?}

    E -- No -→ B

    E -- Yes -→ F[remaining\_time--]

    F -→ G{remaining\_time == 0?}

    G -- No -→ B

    G -- Yes -→ H[Complete cycle]

    H -→ I[Door OPEN]

    I -→ J[Reset to IDLE]

    J -→ B
```

**\## 9. Wash Completion**

When the countdown reaches zero, `timer\_tick()` first sets:

``` text

state          = COMPLETED

door\_status    = DOOR\_OPEN

timer\_running  = 0

start\_requested = 0
```

The code prints:

``` text

Wash cycle completed. Door unlocked.
```

It then immediately resets the machine to `IDLE`:

``` text

mode             = MODE\_NONE

state            = IDLE

door\_status      = DOOR\_OPEN

remaining\_time   = 0

detergent\_present = 0

start\_requested  = 0

timer\_running    = 0
```

So from the user's perspective, completion results in:

``` text

RUNNING

   ↓

COMPLETED

   ↓

IDLE
```

The door is explicitly opened/unlocked as part of completion.

**\## 10. Abort Behavior**

`machine\_abort()` only works when:

``` text

state == RUNNING
```

If a cycle is running:

``` text

state          = ABORTED

door\_status    = DOOR\_OPEN

timer\_running  = 0

start\_requested = 0
```

The code then calls `reset\_to\_idle()`.

Final state:

``` text

mode             = NONE

state            = IDLE

door\_status      = OPEN

remaining\_time   = 0

detergent\_present = 0

start\_requested  = 0

timer\_running    = 0
```

Thus:

``` mermaid

flowchart TD

    A[RUNNING] -→ B[Press Abort]

    B -→ C[State = ABORTED]

    C -→ D[Stop timer]

    D -→ E[Door OPEN]

    E -→ F[reset\_to\_idle]

    F -→ G[IDLE]
```

**\## 11. Power-Off / Power-Failure Handling**

Power behavior is implemented in `power.c`.

When power is switched off:

``` text

power\_present = 0
```

**\### If the machine is RUNNING**

The code preserves the current wash information:

``` text

timer\_running = 0

state         = POWER\_FAILURE

door\_status   = DOOR\_LOCKED

remaining\_time = unchanged
```

The important point is that the remaining time is \*\*\*\*not
reset\*\*\*\*.

Example:

``` text

Normal cycle = 30 minutes

After 8 ticks = 22 minutes remaining

Power OFF

→ POWER\_FAILURE

→ 22 minutes preserved
```

The door remains locked.

**\### If waiting for detergent**

If the machine is:

``` text

WAITING\_FOR\_DETERGENT
```

power failure changes the state to:

``` text

POWER\_FAILURE

door\_status = DOOR\_LOCKED
```

The pending Start request remains stored.

**\### Other states**

For states other than `RUNNING` and `WAITING\_FOR\_DETERGENT`, the code

only turns power off and preserves the current machine state.

``` mermaid

flowchart TD

    A[Power OFF] -→ B[power\_present = 0]

    B -→ C{State RUNNING?}

    C -- Yes -→ D[Stop timer]

    D -→ E[State = POWER\_FAILURE]

    E -→ F[Door LOCKED]

    F -→ G[Preserve remaining time]

    C -- No -→ H{Waiting for detergent?}

    H -- Yes -→ I[State = POWER\_FAILURE]

    I -→ F

    H -- No -→ J[Preserve current state]
```

**\## 12. Power Restoration**

When power is restored:

``` text

power\_present = 1
```

If the previous state was `POWER\_FAILURE`, the code chooses the
recovery

path based on the stored state information.

**\### Interrupted running cycle**

If:

``` text

door\_status == DOOR\_LOCKED

remaining\_time > 0
```

then:

``` text

timer\_running = 1

state = RUNNING
```

The unfinished cycle resumes from the preserved remaining time.

``` mermaid

flowchart TD

    A[Power ON] -→ B{Was state POWER\_FAILURE?}

    B -- No -→ C[Keep current state]

    B -- Yes -→ D{Door locked + remaining time > 0?}

    D -- Yes -→ E[Timer ON]

    E -→ F[State RUNNING]

    D -- No -→ G{Door locked + remaining time = 0 + Start pending?}

    G -- Yes -→ H[State WAITING\_FOR\_DETERGENT]

    H -→ I[Timer OFF]

    G -- No -→ J[State IDLE]

    J -→ K[Door OPEN]
```

**\### Pending detergent case**

If:

``` text

door\_status == DOOR\_LOCKED

remaining\_time == 0

start\_requested == 1
```

power restoration results in:

``` text

state = WAITING\_FOR\_DETERGENT

timer\_running = 0
```

**\### Other power-failure cases**

The machine is reset to:

``` text

state = IDLE

door\_status = DOOR\_OPEN
```

\*\*## 13. Complete Normal Wash Flow

For a direct successful Start operation, the machine must already have a
valid mode, a closed door, and detergent. The timer then runs until
completion.

``` mermaid
flowchart TD
    A[IDLE] --> B[Select wash mode]
    B --> C[Fill detergent]
    C --> D[Close door]
    D --> E[Press Start]
    E --> F{Power ON?}
    F -- No --> X[Reject Start]
    F -- Yes --> G{Valid mode?}
    G -- No --> X
    G -- Yes --> H{Door CLOSED?}
    H -- No --> X
    H -- Yes --> I{Detergent present?}
    I -- No --> J[WAITING_FOR_DETERGENT]
    I -- Yes --> K[Load selected duration]
    K --> L[Lock door]
    L --> M[RUNNING]
    M --> N[Timer tick every second]
    N --> O{Time remaining = 0?}
    O -- No --> N
    O -- Yes --> P[COMPLETED]
    P --> Q[Door OPEN]
    Q --> R[Reset to IDLE]
```

The user can also press Start before filling detergent. That path is
documented separately below.

## 14. Start-Pending Flow

A Start request becomes pending only when the selected mode and door
conditions have already passed, but detergent is missing.

``` mermaid
flowchart TD
    A[IDLE] --> B[Select wash mode]
    B --> C[Close door]
    C --> D[Press Start]
    D --> E{Detergent present?}
    E -- No --> F[Set start_requested = 1]
    F --> G[WAITING_FOR_DETERGENT]
    G --> H[Fill detergent]
    H --> I{Door CLOSED?}
    I -- Yes --> J[Start immediately]
    J --> K[Lock door]
    K --> L[RUNNING]
    I -- No --> M[Wait for door to close]
    M --> N[Close door]
    N --> J
```

If Start is pressed while the door is open, the code rejects the Start
request immediately; it does not create a pending request.

## 15. Power Interruption During a Wash

The key recovery behavior is:

``` mermaid
flowchart TD
    A[RUNNING] --> B[Power OFF]
    B --> C[power_present = 0]
    C --> D[Stop timer]
    D --> E[State = POWER_FAILURE]
    E --> F[Door remains LOCKED]
    F --> G[Preserve remaining time]
    G --> H[Power ON]
    H --> I[Restore power]
    I --> J{Door LOCKED and remaining time > 0?}
    J -- Yes --> K[State = RUNNING]
    K --> L[Timer resumes]
    L --> M[Continue from preserved remaining time]
    J -- No --> N[Use other recovery path]
```

This matches the recovery logic implemented in `power.c`.

## 16. Concurrency and Mutex Protection\*\*

The simulator has two active execution paths:

``` text

Main thread

    └── reads user input and performs machine operations

Timer thread

    └── wakes every second and updates the countdown
```

Both access the same `WashingMachine` structure.

To prevent simultaneous modification of shared state, the code uses:

``` c

pthread\_mutex\_lock(&machine→mutex);

...

pthread\_mutex\_unlock(&machine→mutex);
```

This is used throughout `machine.c`, `timer.c`, and `power.c`.

The timer thread checks `simulator\_running` before calling

`timer\_tick()`.

On exit:

1\. `machine\_shutdown()` sets `simulator\_running = 0`.

2\. `main.c` calls `pthread\_join()`.

3\. The timer thread exits.

4\. `machine\_destroy()` destroys the mutex.

\*\*## 17. High-Level State Transition Diagram

``` mermaid
stateDiagram-v2
    [*] --> IDLE

    IDLE --> WAITING_FOR_DETERGENT: Start with closed door and no detergent
    IDLE --> RUNNING: Start with valid mode + closed door + detergent

    WAITING_FOR_DETERGENT --> RUNNING: Detergent filled with door closed
    WAITING_FOR_DETERGENT --> RUNNING: Door closed after detergent is filled
    WAITING_FOR_DETERGENT --> POWER_FAILURE: Power OFF

    RUNNING --> COMPLETED: Timer reaches 0
    RUNNING --> ABORTED: Abort
    RUNNING --> POWER_FAILURE: Power OFF

    POWER_FAILURE --> RUNNING: Power restored and remaining_time > 0
    POWER_FAILURE --> WAITING_FOR_DETERGENT: Power restored with pending start
    POWER_FAILURE --> IDLE: Other restore case

    COMPLETED --> IDLE: Immediate reset
    ABORTED --> IDLE: Immediate reset
```

## 18. Important Behavior Details\*\*

**\### Door after completion**

The supplied code explicitly changes the door to `DOOR\_OPEN` when a
wash

completes.

**\### Door after abort**

The supplied code explicitly changes the door to `DOOR\_OPEN` when a
wash

is aborted.

**\### Remaining time during power failure**

When power fails during `RUNNING`, the remaining time is preserved. The

timer is stopped until power is restored.

**\### Timer does not run while power is OFF**

`timer\_tick()` returns immediately if `power\_present` is false.

**\### Detergent is consumed/reset at the end of a cycle**

After completion or abort, `reset\_to\_idle()` clears:

``` text

detergent\_present = 0
```

so the next cycle requires detergent again.

**\### Start is not allowed to change an active cycle**

Pressing Start while `RUNNING` is ignored.

**\### Mode cannot be changed during a running cycle**

`machine\_select\_mode()` rejects mode changes while `RUNNING`.

**\### Mode cannot be changed while Start is pending**

If the machine is `WAITING\_FOR\_DETERGENT`, mode selection is rejected

until that pending operation is resolved.

\*\*## 19. File Responsibilities

  -----------------------------------------------------------------------
  File                                Responsibility
  ----------------------------------- -----------------------------------
  `machine.c`                         Core washing-machine state machine,
                                      mode selection, start/abort, door,
                                      and detergent logic

  `timer.c`                           Mode durations, countdown, timer
                                      thread, and completion

  `power.c`                           Power-off behavior and power
                                      restoration

  `machine.h`                         Machine state/data definitions and
                                      function declarations

  `timer.h`                           Timer declarations

  `power.h`                           Power function declarations

  `main.c`                            Program entry point, timer-thread
                                      creation, menu dispatch, and
                                      shutdown

  `input.c/.h`                        Converts menu choices into
                                      `UserInput` values

  `display.c/.h`                      Displays current machine status
  -----------------------------------------------------------------------

The three primary modified logic files are `machine.c`, `timer.c`, and
`power.c`.

## 21. One-Sentence Summary\*\*

The simulator models a washing machine as a

machine in which `machine.c` controls the operating conditions,

`timer.c` drives the simulated wash duration and completion, and

`power.c` preserves and restores an interrupted cycle when power is

lost.




