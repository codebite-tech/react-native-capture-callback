
# react-native-capture-callback

## Getting started
react-native 스크린 캡쳐 후 콜백

`$ npm install react-native-capture-callback --save`

`$ pod install`

## Usage
```javascript
import RNCaptureCallback from 'react-native-capture-callback';

// TODO: What to do with the module?
useEffect(() => {
    const subscription = DeviceEventEmitter.addListener('ScreenshotObserver', (data) => {
      console.log(data);
    });
    RNCaptureCallback.addObserverScreenshot();
    return () => {
      subscription.remove();
    };
  }, []);
```
