:shipit: 

This app will find the closest public transportation to a user.  It takes in the location as a parameter and uses endpoints /train, /bus, /bike.


/train will return:
```
      [  {
        id: 
        name: 
        address: 
        code: 
        latitude: 
        longitude:
        next_train:
          Trains: [
          {Car: 
          Destination: 
          DestinationCode: 
          DestinationName: 
          Group: 
          Line: 
          LocationCode: 
          LocationName: 
          Min: }
          ] 
        }
```
Trains will usually have multiple next_trains.

/bus will return:
```
  {StopName:,
  Predictions:
  [
      {
      RouteID: 
      DirectionText: 
      DirectionNum: 
      Minutes: 
      VehicleID: 
      TripID: 
      },}
```

/bike will return capital bikeshare data:
```
      {
      station_name: 
      bikes_available: 
      empty_docks: 
      distance: 
      }
```
