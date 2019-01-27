## Computing the gravitational field of the particles  

1.Grid methods
----
* the polar coordinate geometies that concentrate spatial resolution at the geometric center of the grid, which coincides with the highest density of particles in simulations of galaxies.  
* a significant limitationof grid methods is that self-consistent forces cannot be computed for particles outside the grid volume. (but their motion can be advanced using one of a number of different approximations).  

2.Field methods
----
* compute the field from an expansion in some suitably chosen set of basis functions, which is called 'smooth-field particle' method (SFP).  
* these methods are ideal for checking the stability of equilibrium models, or for measuring relaxation rates in equilibrium models, but for little else.

3.Direct methods
----
* the least efficient, but most flexible methods determine the gravitational forces directly from the particles.  
* it is the direct summation of the forces over all particles pairs.
* tree codes approximate the forces from distant groupings of particles, and therefore do not yield quite such accurate forces, but the approximation leads to a substantial speed up over the direct-N approach (the tree code offered here is not well optimized, better looking for a state-of-art tree code somewhere else).
* it is very useful to introduce a set of very heavy particles whose motion and interactions with more numerous lighter particles and be computed directly.

4.hybrid
----
<dl>
<dt>hybrid = T<dt>
<dd>two concentric grids</dd>
this is useful when computing a disk (cylindrical polar grid) + a bulge/halo component (sherical grid). (also see Sellwood 2003)
<dt>twogrd = T</dt>
<dd>two grids with different centers.</dd>
This is used to compute the internal dynamics of two interacting but initially separate systems (this option still needs further improvement).
<dt>heavies = T</dt>
useful to compute a sea of light particles using a grid method while including a small number of heavy particles whose attractions are computed directly. (also see Jardel & Sellwood 2009)
</dl>

Grid noise in Polar Grids
----
The collisionless simulations are not concerned with forces between individual particles, since each particle is supposed to experience only the mean attraction of large-scale mass distribution. The variation of the forces between individual particles re not a cause for concern. However, for calculations that yield important results, the user should rerun with a finer grid in order to verify that grid noise is not affecting results.  

Local buffer
----
The code advances particles in groups of up to 1000, keeping a wide variety of information about each in a local buffer. They are processed in the following manner:  
<ol>
	<li>A call to **gather** collects the next group of particles in the current chain from the main array **ptcls**. This routine places a copy of their coordinates at the start of the step in the local array **oldc** and also decodes any flags.</li>
	<li>The accelerations to be applied to each of these particles are determined in a call to **getacc** and stored in array **acc**. They are generally interpolated from the grid and may include externally applied accelerations.</li>
	<li>If this is an analysis step, a call to **anlgrp** will cause the contributions of this group of particles to be added to the cumulative analysis of the model. The needed initial coordinates and accelerations have previously been assemebled.</li>
	<li>The motion of each particle is advanced in a call to **stpgrp**, which places the updated coordinates in the array **newc**. This routine also flags any particles that leave the grid at this step.</li>
	<li>A call to **scattr** copies the updated coordinates of each particle in the group, temporarily stored in array **newc**, back to its original location in the main particle array, and updates the linked list for whichever zone they are in.</li>
	<li>Finally, the mass of each particle at its updated position is assigned to the grid array that accumulates the masses of particles in each zone by a call to **massgn**.</li>
</ol>

off-grid particles
----
if the evolution remains of interest after a significant fraction (5%) of the particles have left the grid, the user should restart the simulation with a smaller value of **lscale** in order that the initial particle distribution occupies a smaller fraction of the grid volume.