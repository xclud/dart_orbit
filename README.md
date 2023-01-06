[![pub package](https://img.shields.io/pub/v/orbit)](https://pub.dartlang.org/packages/orbit)
[![likes](https://img.shields.io/pub/likes/orbit)](https://pub.dartlang.org/packages/orbit/score)
[![points](https://img.shields.io/pub/points/orbit)](https://pub.dartlang.org/packages/orbit/score)
[![popularity](https://img.shields.io/pub/popularity/orbit)](https://pub.dartlang.org/packages/orbit/score)
[![license](https://img.shields.io/github/license/xclud/dart_orbit)](https://pub.dartlang.org/packages/orbit)
[![stars](https://img.shields.io/github/stars/xclud/dart_orbit)](https://github.com/xclud/dart_orbit/stargazers)
[![sdk version](https://badgen.net/pub/sdk-version/orbit)](https://pub.dartlang.org/packages/orbit)

TLE and NORAD SGP4/SDP4/SGP8/SDP8 Implementation for Dart and Flutter.

## Demo

[Web Demo](https://orbit.pwa.ir)

## Features

* TLE (Two-Line Element) parsing.
* Keplerian Elements.
* SGP4, SDP4, SGP8 and SDP8 Implementation.
* Propagation of Satellites.
* Rise and Set times for Satellites.
* Look angle calculation from the observer location on the planet.
* Earth WGS72 and WGS84 and generic planet.
* Ground Track calculation.

## Usage

In your `pubspec.yaml` file add:

```yaml
dependencies:
  orbit: any
```

Then, in your code import:

```dart
import 'package:orbit/orbit.dart';
```

## Additional information

The **Keplerian Elements**

Seven numbers are required to define a satellite orbit. This set of seven numbers is called the satellite orbital elements, or sometimes “Keplerian” elements (after Johann Kepler [1571-1630]), or just elements. These numbers define an ellipse, orient it about the earth, and place the satellite on the ellipse at a particular time. In the Keplerian model, satellites orbit in an ellipse of constant shape and orientation. The Earth is at one focus of the ellipse, not the center (unless the orbit ellipse is actually a perfect circle).

The real world is slightly more complex than the Keplerian model, and tracking programs compensate for this by introducing minor corrections to the Keplerian model. These corrections are known as perturbations. The perturbations that amateur tracking programs know about are due to the lumpiness of the earth’s gravitational field (which luckily you don’t have to specify), and the “drag” on the satellite due to atmosphere. Drag becomes an optional eighth orbital element.

Orbital elements remain a mystery to most people. This is due I think first to the aversion many people (including me) have to thinking in three dimensions, and second to the horrible names the ancient astronomers gave these seven simple numbers and a few related concepts. To make matters worse, sometimes several different names are used to specify the same number. Vocabulary is the hardest part of celestial mechanics!

The basic orbital elements are:

* Epoch
* Inclination
* Right Ascension of Ascending Node
* Argument of Periapsis
* Eccentricity
* Mean Motion
* Mean Anomaly
* Drag (optional)

### Epoch

A set of orbital elements is a snapshot, at a particular time, of the orbit of a satellite. Epoch is simply a number which specifies the time at which the snapshot was taken.

### Inclination

The orbit ellipse lies in a plane known as the orbital plane. The orbital plane always goes through the center of the earth, but may be tilted any angle relative to the equator. Inclination is the angle between the orbital plane and the equatorial plane. By convention, inclination is a number between 0 and 180 degrees.

Orbits with inclination near 0 degrees are called equatorial orbits (because the satellite stays nearly over the equator). Orbits with inclination near 90 degrees are called polar (because the satellite crosses over the north and south poles). The intersection of the equatorial plane and the orbital plane is a line which is called the line of nodes. More about that later.

### Right Ascension of Ascending Node

Two numbers orient the orbital plane in space. The first number was Inclination. This is the second. After we’ve specified inclination, there are still an infinite number of orbital planes possible. The line of nodes can poke out the anywhere along the equator. If we specify where along the equator the line of nodes pokes out, we will have the orbital plane fully specified. The line of nodes pokes out two places, of course. We only need to specify one of them. One is called the ascending node (where the satellite crosses the equator going from south to north). The other is called the descending node (where the satellite crosses the equator going from north to south). By convention, we specify the location of the ascending node.

Now, the earth is spinning. This means that we can’t use the common latitude/longitude coordinate system to specify where the line of nodes points. Instead, we use an astronomical coordinate system, known as the right ascension / declination coordinate system, which does not spin with the earth. Right ascension is another fancy word for an angle, in this case, an angle measured in the equatorial plane from a reference point in the sky where right ascension is defined to be zero. Astronomers call this point the vernal equinox.

Finally, “right ascension of ascending node” is an angle, measured at the center of the earth, from the vernal equinox to the ascending node.

I know this is getting complicated. Here’s an example. Draw a line from the center of the earth to the point where our satellite crosses the equator (going from south to north). If this line points directly at the vernal equinox, then RAAN = 0 degrees.

By convention, RAAN is a number in the range 0 to 360 degrees.

I used the term “vernal equinox” above without really defining it. If you can tolerate a minor digression, I’ll do that now. Teachers have told children for years that the vernal equinox is “the place in the sky where the sun rises on the first day of Spring”. This is a horrible definition. Most teachers, and students, have no idea what the first day of spring is (except a date on a calendar), and no idea why the sun should be in the same place in the sky on that date every year.

You now have enough astronomy vocabulary to get a better definition. Consider the orbit of the sun around the earth. I know in school they told you the earth orbits around the sun, but the math is equally valid either way, and it suits our needs at this instant to think of the sun orbiting the earth. The orbit of the sun has an inclination of about 23.5 degrees. (Astronomers don’t usually call this 23.5 degree angle an ‘inclination’, by the way. They use an infinitely more obscure name: The Obliquity of The Ecliptic.) The orbit of the sun is divided (by humans) into four equally sized portions called seasons. The one called Spring begins when the sun pops up past the equator. In other words, the first day of Spring is the day that the sun crosses through the equatorial plane going from South to North. We have a name for that! It’s the ascending node of the Sun’s orbit. So finally, the vernal equinox is nothing more than the ascending node of the Sun’s orbit. The Sun’s orbit has RAAN = 0 simply because we’ve defined the Sun’s ascending node as the place from which all ascending nodes are measured. The RAAN of your satellite’s orbit is just the angle (measured at the center of the earth) between the place the Sun’s orbit pops up past the equator, and the place your satellite’s orbit pops up past the equator.

### Argument of Periapsis

Now that we’ve oriented the orbital plane in space, we need to orient the orbit ellipse in the orbital plane. We do this by specifying a single angle known as argument of periapsis.

A few words about elliptical orbits… The point where the satellite is closest to the earth is called perigee, although it’s sometimes called periapsis or perifocus. We’ll call it perigee. The point where the satellite is farthest from earth is called apogee (aka apoapsis, or apifocus). If we draw a line from perigee to apogee, this line is called the line-of-apsides. (Apsides is, of course, the plural of apsis.) I know, this is getting complicated again. Sometimes the line-of-apsides is called the major-axis of the ellipse. It’s just a line drawn through the ellipse the “long way”.

The line-of-apsides passes through the center of the earth. We’ve already identified another line passing through the center of the earth: the line of nodes. The angle between these two lines is called the argument of perigee. Where any two lines intersect, they form two supplementary angles, so to be specific, we say that argument of perigee is the angle (measured at the center of the earth) from the ascending node to perigee.

Example: When ARGP = 0, the perigee occurs at the same place as the ascending node. That means that the satellite would be closest to earth just as it rises up over the equator. When ARGP = 180 degrees, apogee would occur at the same place as the ascending node. That means that the satellite would be farthest from earth just as it rises up over the equator.

By convention, ARGP is an angle between 0 and 360 degrees.

### Eccentricity

This one is simple. In the Keplerian orbit model, the satellite orbit is an ellipse. Eccentricity tells us the “shape” of the ellipse. When e=0, the ellipse is a circle. When e is very near 1, the ellipse is very long and skinny.

To be precise, the Keplerian orbit is a conic section, which can be either an ellipse, which includes circles, a parabola, a hyperbola, or a straight line! But here, we are only interested in elliptical orbits. The other kinds of orbits are not used for satellites, at least not on purpose, and tracking programs typically aren’t programmed to handle them.

For our purposes, eccentricity must be in the range 0 <= e < 1.

### Mean Motion

So far we’ve nailed down the orientation of the orbital plane, the orientation of the orbit ellipse in the orbital plane, and the shape of the orbit ellipse. Now we need to know the “size” of the orbit ellipse. In other words, how far away is the satellite?

Kepler’s third law of orbital motion gives us a precise relationship between the speed of the satellite and its distance from the earth. Satellites that are close to the earth orbit very quickly. Satellites far away orbit slowly. This means that we could accomplish the same thing by specifying either the speed at which the satellite is moving, or its distance from the earth!

Satellites in circular orbits travel at a constant speed. Simple. We just specify that speed, and we’re done. Satellites in non-circular (i.e., eccentricity > 0) orbits move faster when they are closer to the earth, and slower when they are farther away. The common practice is to average the speed. You could call this number “average speed”, but astronomers call it the “Mean Motion”. Mean Motion is usually given in units of revolutions per day.

In this context, a revolution or period is defined as the time from one perigee to the next.

Sometimes “orbit period” is specified as an orbital element instead of Mean Motion. Period is simply the reciprocal of Mean Motion. A satellite with a Mean Motion of 2 revs per day, for example, has a period of 12 hours.

Sometimes semi-major-axis (SMA) is specified instead of Mean Motion. SMA is one-half the length (measured the long way) of the orbit ellipse, and is directly related to mean motion by a simple equation.

Typically, satellites have Mean Motions in the range of 1 rev/day to about 16 rev/day.

### Mean Anomaly

Now that we have the size, shape, and orientation of the orbit firmly established, the only thing left to do is specify where exactly the satellite is on this orbit ellipse at some particular time. Our very first orbital element (Epoch) specified a particular time, so all we need to do now is specify where, on the ellipse, our satellite was exactly at the Epoch time.

Anomaly is yet another astronomer-word for angle. Mean anomaly is simply an angle that marches uniformly in time from 0 to 360 degrees during one revolution. It is defined to be 0 degrees at perigee, and therefore is 180 degrees at apogee.

If you had a satellite in a circular orbit (therefore moving at constant speed) and you stood in the center of the earth and measured this angle from perigee, you would point directly at the satellite. Satellites in non-circular orbits move at a non-constant speed, so this simple relation doesn’t hold. This relation does hold for two important points on the orbit, however, no matter what the eccentricity. Perigee always occurs at MA = 0, and apogee always occurs at MA = 180 degrees.

It has become common practice with radio amateur satellites to use Mean Anomaly to schedule satellite operations. Satellites commonly change modes or turn on or off at specific places in their orbits, specified by Mean Anomaly. Unfortunately, when used this way, it is common to specify MA in units of 256ths of a circle instead of degrees! Some tracking programs use the term “phase” when they display MA in these units. It is still specified in degrees, between 0 and 360, when entered as an orbital element.

Example: Suppose Oscar-99 has a period of 12 hours, and is turned off from Phase 240 to 16. That means it’s off for 32 ticks of phase. There are 256 of these ticks in the entire 12 hour orbit, so it’s off for (32/256)x12hrs = 1.5 hours. Note that the off time is centered on perigee. Satellites in highly eccentric orbits are often turned off near perigee when they’re moving the fastest, and therefore difficult to use.

### Drag

Drag caused by the earth’s atmosphere causes satellites to spiral downward. As they spiral downward, they speed up. The Drag orbital element simply tells us the rate at which Mean Motion is changing due to drag or other related effects. Precisely, Drag is one half the first time derivative of Mean Motion.

Its units are revolutions per day per day. It is typically a very small number. Common values for low-earth-orbiting satellites are on the order of 10^-4. Common values for high-orbiting satellites are on the order of 10^-7 or smaller.

Occasionally, published orbital elements for a high-orbiting satellite will show a negative Drag! At first, this may seem absurd. Drag due to friction with the earth’s atmosphere can only make a satellite spiral downward, never upward.

There are several potential reasons for negative drag. First, the measurement which produced the orbital elements may have been in error. It is common to estimate orbital elements from a small number of observations made over a short period of time. With such measurements, it is extremely difficult to estimate Drag. Very ordinary small errors in measurement can produce a small negative drag.

The second potential cause for a negative drag in published elements is a little more complex. A satellite is subject to many forces besides the two we have discussed so far (earth’s gravity, and atmospheric drag). Some of these forces (for example gravity of the sun and moon) may act together to cause a satellite to be pulled upward by a very slight amount. This can happen if the Sun and Moon are aligned with the satellite’s orbit in a particular way. If the orbit is measured when this is happening, a small negative Drag term may actually provide the best possible ‘fit’ to the actual satellite motion over a *short* period of time.

You typically want a set of orbital elements to estimate the position of a satellite reasonably well for as long as possible, often several months. Negative Drag never accurately reflects what’s happening over a long period of time. Some programs will accept negative values for Drag, but I don’t approve of them. Feel free to substitute zero in place of any published negative Drag value.

Other Satellite Parameters
All the satellite parameters described below are optional. They allow tracking programs to provide more information that may be useful or fun.

### Revolution Number at Epoch

This tells the tracking program how many times the satellite has orbited from the time it was launched until the time specified by “Epoch”. Epoch Rev is used to calculate the revolution number displayed by the tracking program. Don’t be surprised if you find that orbital element sets which come from NASA have incorrect values for Epoch Rev. The folks who compute satellite orbits don’t tend to pay a great deal of attention to this number! At the time of this writing [1989], elements from NASA have an incorrect Epoch Rev for Oscar-10 and Oscar-13. Unless you use the revolution number for your own bookeeping purposes, you needn’t worry about the accuracy of Epoch Rev.

### Attitude

The spacecraft attitude is a measure of how the satellite is oriented in space. Hopefully, it is oriented so that its antennas point toward you! There are several orientation schemes used in satellites. The Bahn coordinates apply only to spacecraft which are spin-stablized. Spin-stabilized satellites maintain a constant inertial orientation, i.e., its antennas point a fixed direction in space (examples: Oscar-10, Oscar-13). This is also known as Bahn Coordinates.

The Bahn Coordinates consist of two angles, often called Bahn Latitude and Bahn Longitude. These are published from time to time for the elliptical-orbit amateur radio satellites in various amateur satellite publications. Ideally, these numbers remain constant except when the spacecraft controllers are re-orienting the spacecraft. In practice, they drift slowly.

For highly elliptical orbits (Oscar-10, Oscar-13, etc.) these numbers are usually in the vicinity of: 0,180. This means that the antennas point directly toward earth when the satellite is at apogee.

These two numbers describe a direction in a spherical coordinate system, just as geographic latitude and longitude describe a direction from the center of the earth. In this case, however, the primary axis is along the vector from the satellite to the center of the earth when the satellite is at perigee.

An excellent description of Bahn coordinates can be found in Phil Karn’s “Bahn Coordinates Guide”.
