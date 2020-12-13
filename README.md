# ARMeshSniffer

AR App with ScneneKit for sniffing data from an AR Session frame (vertices, jpeg data, some cam params), and synchronously save it to a binary file

### Prerequisites

iPhone X and above, iOS 13.4 and above

### Pattern

MVVM

### Main Phases

* Launch an ARSession with FaceTracking Configuration
* Draw a face mesh on tracked face
* For each frame in renderer call, parse FaceAncor geometry to receive:
    • 3D vertices (it's a SIMD3<Float> each)
    • CVPixelBuffer from captured image
    • Data on cam (size, exposure)

  Intercepting frame done on background (OperationQueue) and one after another, to acheive sequntially 
  order in frames recording. Thus, vertices and jpeg Data for each frame is synchronised.
* After user stops session, all recorded data shall be displayed on output console of Xcode
* Another sample shall be save to pdf in Device Apps data (requires approval)

### Pipeline of recoding

IMPORTANT: App dispatches data to file as it runs (on the background) and NOT only in the end.
Thanks to that, RAM footprint won't grow exponentially, thus allowing app to RUN FOR A LONG TIME.
Another solution would be to save all data in RAM first, and only when session end, pass it to file. But that
will bring a rapid overflow memory, allowing app to run only for a very short time (since we'll have a lot of data)

### Profiling

CPU, memory and disk results are steady thanks to recording pipeling explained above.
Examples (iPhone X):

![screenshot](/Profiling/profile_CPU.png)
![screenshot](/Profiling/profile_mem.png)
![screenshot](/Profiling/profile_disk.png)


### License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

