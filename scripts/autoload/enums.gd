extends Node

enum BallType { NONE, CUE, EIGHT, FULL, HALF }
enum PocketLocation { NONE, UP_LEFT, UP, UP_RIGHT, DOWN_LEFT, DOWN, DOWN_RIGHT }
enum GameState { NONE, QUEUE, ROLLING, BALL_IN_HAND, WAITING }
enum ShotResult { NONE, LEGAL, POCKETED, FOULED }
enum QueueMode { DRAG, MOUSE_WHEEL, KEYBOARD }
