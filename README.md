KinectWings
===========
http://github.com/johnboiles/KinectWings

Quadcopter controller using Kinect.

To build using the xcode project, you must symlink /usr/include/ni and
/usr/lib/libOpenNI.dylib to the appropriate places in your developer install.
AFAIK there's not an elegant way to get xcode to use the standard /usr/include
and /usr/lib paths. For my installation I ran the following commands:

<pre>sudo ln -s /usr/lib/libOpenNI.dylib /Developer/SDKs/MacOSX10.6.sdk/usr/lib/libOpenNI.dylib</pre>

<pre>sudo ln -s /usr/include/ni /Developer/SDKs/MacOSX10.6.sdk/usr/include/ni</pre>

To Install OpenNI for Mac
-------------------------
1.   Get OpenNI
     <pre>git clone git://github.com/OpenNI/OpenNI.git</pre>

2.   Switch to unstable branch
     <pre>git checkout unstable</pre>

3.   Follow the installation instructions in the OpenNI Readme (they're pretty good)

4.   Install forked binaries for PrimeSense/Sensor
     https://github.com/avin2/SensorKinect/tree/unstable/Bin

5.   Get the PrimeSense NITE binaries here:
     http://www.openni.org/component/search/?searchword=nite&ordering=&searchphrase=all

6.   Run the install script included with the NITE binaries
     <pre>sudo ./install.sh</pre>

7.   Use License code
     <pre>0KOIk2JeIBYClPWVnMoRKn5cdY4=</pre>

TODO / Future Vision
--------------------
In The future it might make sense to use the C bindings for OpenNI and make Cocoa wrappers
around those. Currently this uses the C++ bindings which is a little roundabout. But it
was generally easier to port over existing C++ sample code that I had available.