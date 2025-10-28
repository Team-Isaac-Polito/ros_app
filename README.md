# isaac_app
This is an application to communicate with isaac robot(s).

## Getting Started

lib/ -> the app code
    features/ -> all the app features
      feature1/
          presentation/ -> (graphic interface and components)
          model(s)/ -> all class models
          logic/ -> all the logic functions, providers and controllers
      ...
   utils/ -> constants, API, ecc
   shared/ -> widgets, themes, constants shared among features

in test/ you can find all the test of every feature

The state manager is riverpod.dev because it's very easy to learn, and doesn't do
big tree injections and we can make our code more cleaner.
