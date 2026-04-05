# Breakout

<img src="breakout.p8.png"/>

A classic Breakout clone built with [PICO-8](https://www.lexaloffle.com/pico-8.php). Destroy bricks with a bouncing ball, collect power-ups, and clear 3 levels of increasingly complex layouts featuring normal, hard, indestructible, exploding, and power-up bricks.

## Play Game

https://is386.itch.io/breakout

## Setup

1. Install [PICO-8](https://www.lexaloffle.com/pico-8.php)
2. Open the cartridge:
   ```
   load breakout.p8
   run
   ```

## How to Play

- **Left/Right arrows** — Move the paddle
- **X** — Launch the ball / start the game

Break all destructible bricks to complete a level. You start with 3 lives and lose one each time the ball falls past the paddle.

### Brick Types

| Color | Type | Description |
|-------|------|-------------|
| Blue | Normal | Destroyed in one hit |
| Dark Purple | Hard | Takes two hits to destroy |
| Dark Gray | Indestructible | Cannot be destroyed |
| Orange | Exploding | Destroys adjacent bricks on hit |
| Light Blue | Power-Up | Drops a random power-up when destroyed |

### Power-Ups

- **Extra Life** — Gain an additional life
- **Catch** — Ball sticks to the paddle on contact (timed)
- **Mega Ball** — Ball destroys hard bricks in one hit (timed)
- **Widen** — Increases paddle width (timed)
- **Double Points** — 2x score multiplier (timed)
