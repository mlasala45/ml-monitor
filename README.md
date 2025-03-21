# ML-Monitor

ML-Monitor is a tool that receives reports from ongoing machine learning tasks, and relays them to your phone for convenient viewing. This also allows you to receive notifications when a task is done, allowing you to more freely work on other tasks while a model is training.

> [!NOTE]

> This repository only contains the sources for the tool. You can build it yourself, but there is not an official prebuilt release at this time.

> [!NOTE]

> The app is only designed for Android use at this time. iOS is not supported.

## About
The user runs a **Node.Js server** that acts as a relay between the ML worker and the mobile device.
The worker regularly sends *events* over HTTP to the server. The event types are:

 - Job started
 - Progress update (usually Epoch finished)
 - Job finished

The server communicates with the app through Firebase Cloud Messaging (FCM). You can view progress in the app, or just leave it running in the background, and you will receive an audible notification when the job is done.

## Repo contents
`/native` - Source for the android app. Written in React Native.
`/server` - Node.Js monitoring server. Can be run as-is.
`/julia` - Julia module for dispatching events.

## Planned work

 - Official builds
 - Support for "experiments" which can act as parent processes to a series of jobs
- In-app notification settings and polish
- Python worker reporting module