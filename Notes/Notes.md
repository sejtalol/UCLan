## Model setting-up
<ol>
    <li>Disk has intial Toomre-Q = 1.5, and truncates at R = 6.</li>
    <li>Halo is rigid, with HERN index = 20, truncates at R = 500.</li>
    <li>Pattern speed (from <b>modefit</b>) &Omega;<sub>bar</sub> = 0.542, &Omega;<sub>spiral</sub> = 0.228</li>
    <li>The corresponding co-rotation radius (estimated from <b>spct</b>) R<sub>bar</sub> ~ 3.2, and R<sub>spiral</sub> ~ 7.0</li>
</ol>

All the following analysis is in <b>simulation units</b>.

<img src="./output/Dens_xy_t150.png" />

Here is the face-on bar-spiral model.

1.Angular momentum vs. R
----
The radial distribution of L<sub>Z</sub> at T = 150.

<img src="./output/Lz_R_t150_color.png">  

Note: vertical dash lines show the position of <b>corotaion radius of bar (left) and spiral (right)</b>, estimated from subroutine <b>spct</b> with the pattern speed (i.e. &Omega;<sub>bar</sub> = 0.542, &Omega;<sub>spiral</sub> = 0.228).

2.Energy vs. R
----
The radial distribution of energy ( potential + kinetic ) at T = 150.

<img src="./output/Te_R_t150.png" /> 

3.Ej vs. R
----
The radial distribution of <b>Jacobi energy E<sub>J</sub></b>:   
<img src="./output/Latex.gif" />  
at T = 150.  

<ul>
	<li><img src="http://latex.codecogs.com/gif.latex?$$|\dot{\mathbf{r}}|^{2}$$  " border="0"/> term is in the <b>rotating frame</b>;</li>
	<li>unequal mass is used.</li>  
</ul>  

<img src="./output/Ej_R_t150_color.png" />  

4.change of the Jacobi Energy
----
The change of <b>Jacobi energy E<sub>J</sub> </b> in &Delta;t =10 ( <b>T = 150 ~ 160</b> )  
E<sub>J</sub> in x-axis is the Jacobi energy at T=150;  
&Delta;E<sub>J</sub> is the difference between two times.  

<img src="./output/dEj_t150_to_160_color.png" />                                                     

5.change of angular momentum
----
The change of <b>Angular Momentum L<sub>z</sub></b> in &Delta;t =10 ( <b>T = 150 ~ 160</b> )  
L<sub>Z</sub> in x-axis is the angular momentum at T=150;  
&Delta;L<sub>Z</sub> is the difference between two times.  

<img src="./output/da_t150_to_160_color.png" />                                                

6.Comparison with longer time intervals ( &Delta;t = 10 and &Delta;t = 50 )
----

### Jacobi Energy

<img src="./output/dEj_t150_cmp.png" />                                                     


### Angular Momentum

<img src="./output/da_t150_cmp.png" />                                                     

7.Distribution of Jacobi energy in (x, y) plane (T=150)
----
<img src="./output/Ej_xy_t150.png" />

If dvided into several sub-populations:  
<img src="./output/Ej_dens_t150_cmp.png" />      

8.Distribution of angular momentum in (x, y) plane (T=150)
----
<img src="./output/Lz_dens_t150_cmp.png" />  

9.Ej vs. Mass
----
<img src="./output/Ej_Mass_t150_color.png" />  

NOTE: mainly around 2.0

## Bar model
<ul>
	<font size="+0.5">
	<li>Pattern speed = 0.548</li>
	<li>No groove mode, no inner taper, initial Toomre Q = 1.8;</li>
	<li>bar corotation radius ~ 3.4</li>
</ul>  

<img src="../data_bar/output/Dens_xy_t150.png" />

Comparison with longer time intervals ( &Delta;t = 10 and &Delta;t = 50 )
----

### Jacobi Energy

<img src="../data_bar/output/dEj_t150_cmp.png" />                                                     


### Angular Momentum

<img src="../data_bar/output/da_t150_cmp.png" />     


Notes:
----
For bar-spiral model:
<ol>
	<li>Bar particles (－4.0 < E<sub>J</sub> < -2.0) <b>conserved btter</b> than the particles around bar corotation radius (－6.0 < E<sub>J</sub> < -4.0).</li>
	<li>We see a clear ridge around －6.0 < E<sub>J</sub> < -4.0 in E<sub>J</sub> map, this corresponds to the <b>bar corotation ~ 3.2</b>, see section 7, second fig.</li>
	<li>Particle with Jacobi Energy -6.0 < E<sub>J</sub> < -4.0 (around the bar corotation radius) changes more significantly at longer time scale.</li>
	<li>Also, we see the feature appears in the &Delta;E<sub>J</sub> - E<sub>J</sub> map around E<sub>J</sub> ~ -13.</li>
	<li>As for the L<sub>Z</sub>, bar particles with angular momentum (0 < L<sub>Z</sub> < 2.0) transfered the angular momentum efficiently; while the particles around the corotation,</li>
</ol>

To compare with the bar model
<ol>
	<li>Only the bar-spiral model show the change of angular momentum at around L<sub>Z</sub> ~ 7.0, i.e., <b>around the spiral corotation</b>.</li>
	<li>The feature at lager E<sub>J</sub> does not appear at longer timescale, only the particle with -6.0 < E<sub>J</sub> < -4.0 (around the bar corotation radius) changes more significantly.</li>
</ol>