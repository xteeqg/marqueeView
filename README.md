## A simple and easy-to-use marquee plugin
- supports from any widget to marquee.
- Supports interaction and can respond to child events.
- Supports other basic functions.

## MarqueeView

| Argument                       | Type              | Description                                 | Required | Default              |
| ------------------------------ | ----------------- | ------------------------------------------- | -------- | -------------------- |
| child                          | Widget            |                                             | true     | -                    |
| width                          | double            | Marquee width                               | false    | null                 |
| height                         | double            | Marquee width                               | false    | null                 |
| backgroundColor                | Color             | BackgroundColor                             | false    | null                 |
| controller                     | MarqueeController | Controller                                  | false    | null                 |
| direction                      | MarqueeDirection  | Scroll direction                            | false    | MarqueeDirection.rtl |
| padding                        | double            | Content padding in the scrolling direction  | false    | 0                    |
| spacing                        | double            | The spacing between the children of marquee | false    | 100                  |
| pps                            | double            | Pixel per second                            | false    | 30                   |
| autoStart                      | bool              | Auto start                                  | false    | true                 | 
| autoStartDelayed               | Duration          | Auto Start delayed duration                 | false    | 100.milliseconds     |
| interaction                    | bool              | Interactions                                | false    | false                |
| restartAfterInteraction        | bool              | Restart after interaction stops             | false    | true                 |
| restartAfterInteractionDelayed | Duration          | Restart after interaction stops delayed     | false    | 1.seconds            |

## Basic Usage

```dart
final marqueeController = MarqueeController();

// marqueeController.start();
// marqueeController.stop();
// marqueeController.reset();

MarqueeView(
  height: 44,
  // direction: MarqueeDirection.rtl,
  // padding: screenWidth,
  spacing: 200,
  pps: 30,
  autoStart: true,
  // interaction: true,
  // restartAfterInteraction: true,
  // restartAfterInteractionDelayed: const Duration(seconds: 1),
  child: const Text(
    "A long time ago, I had a dream, I want this day, no longer cover my eyes, I want this land, no longer bury my heart.",
  ),
);
```
For more information about the properties, have a look at the API reference, Thanks.
