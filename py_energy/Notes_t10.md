## Model setting-up
<ol>
    <li>Disk has intial Toomre-Q = 1.5, and truncates at R = 6.</li>
    <li>Halo is rigid, with HERN index = 20, truncates at R = 500.</li>
    <li>Pattern speed (from <b>modefit</b>) &Omega;<sub>bar</sub> = 0.542, &Omega;<sub>spiral</sub> = 0.228</li>
    <li>The corresponding co-rotation radius (estimated from <b>spct</b>) R<sub>bar</sub> ~ 3.2, and R<sub>spiral</sub> ~ 7.0</li>
</ol>

All the following analysis is in <b>simulation units</b>.

1.Angular momentum vs. R
----
The radial distribution of L<sub>Z</sub> at T = 160.

<img src="./output/Lz_R_t160_color.png">  

Note: vertical dash lines show the position of <b>corotaion radius of bar (left) and spiral (right)</b>, estimated from subroutine <b>spct</b> with the pattern speed (i.e. &Omega;<sub>bar</sub> = 0.542, &Omega;<sub>spiral</sub> = 0.228).

We can see in this figure:  
<ul>
    <li>inside the <b>R<sub>CR</sub> of bar</b> --> mainly <b>L<sub>Z</sub> < 7.5.</b> </li> 
    <li>around the <b>R<sub>CR</sub> of spiral</b> --> mainly <b>5 < L<sub>Z</sub> < 10.</b> </li>
</ul>

2.Energy vs. R
----
The radial distribution of energy ( potential + kinetic ) at T = 160.

<img src="./output/Te_R_t160.png" /> 

3.Ej vs. R
----
The radial distribution of <b>Jacobi energy E<sub>J</sub> ( E<sub>J</sub> = E - &Omega;<sub>P</sub> &#10005; L<sub>Z</sub> )</b> at T = 160.  

<img src="./output/Ej_R_t160_color.png" />  

<ul>
    <li>inside the <b>R<sub>CR</sub> of bar</b> --> mainly <b>E<sub>J</sub> > -6.0 ( especially around -4.0 ).</b> </li> 
    <li>around the <b>R<sub>CR</sub> of spiral</b> --> mainly <b> -7.5 < E<sub>J</sub> < -5.0. </b> </li>
</ul>

4.change of the Jacobi Energy
----
The change of <b>Jacobi energy E<sub>J</sub> </b> in &Delta;t =10 ( <b>T = 150 ~ 160</b> )  
E<sub>J</sub> in x-axis is the Jacobi energy at T=150;
&Delta;E<sub>J</sub> is the difference between two times.

<img src="./output/dEj_Ej2_t160_color.png" />                                                     

Possible Features:      
<ol>
    <li>E<sub>J</sub> ~ -3.0 ( very small fraction in bar, but is the <b>highest number density region</b> in this figure )</li>
    <li>E<sub>J</sub> ~ -4.0 ( correspond to the <b>highest number density region in E<sub>J</sub> vs. R figure</b> )</li>
    <li>E<sub>J</sub> ~ -5.5 ( correspond to a very wide range, not sure this structure is due to <b>the CR of spiral</b> )</li> 
</ol>

5.change of angular momentum
----
The change of <b>Angular Momentum L<sub>z</sub></b> in &Delta;t =10 ( <b>T = 150 ~ 160</b> )
L<sub>Z</sub> in x-axis is the angular momentum at T=150;
&Delta;L<sub>Z</sub> is the difference between two times.

<img src="./output/da_a2_t160_color.png" />                                                     

Density peaks:  
<ol>
    <li>L<sub>Z</sub> < 2.0 ( all of the particles are <b>inside CR of bar.</b> )</li>
    <li>2.5 < L<sub>Z</sub> < 5.0 ( wide range of particles, not sure about the origin of these structures. But some of them should be related to <b>the CR of bar</b>. )</li>
    <li>L<sub>Z</sub> ~ 9. ( should be due to <b>the CR of spiral</b> )</li> 
</ol>

6.Notes
----
<ul>
    <font size="+0.5">
    <li>Note this is only the evolution in a very small range of particles, thus the L<sub>Z</sub> transfer around the CR of spirals <b>should be very mild</b>. If we use a longer time interval, we expect <b>the structure in L<sub>Z</sub> - &Delta;L<sub>Z</sub></b> should be more prominent for particles with L<sub>Z</sub> ~ 9. </li>
    <li>Due to the wide range of the L<sub>Z</sub> and E<sub>J</sub> distribution in Radius, we are not sure whether these structures are really induced by these resonances (e.g. ILR, CR, OLR) at present.</li>
    </font>
</ul>