Notes
----
<ol>
	<li>before step or after step? (before step to keep in line with on-the-fly position and velocity, but the potential & acceleration is not changed in each leap-frog step actually)</li>
	<li>small group or all the particles? (all the particles)</li>
	<li>only at phys? (yes)</li>
</ol>

To do
----
<ol>
	<li>back up the old galaxy, step and icheck file (28/Jan/2019).</li>
	<li>don't forget the <b>rebuild, make, and make clean</b>.</li>
	<li>make a single call to <b>anlgrp</b>? it is only available for <em>jst</em> group</li>
	<li>make a test to all the parameters in each step, to see the change of each parameter in and after <b>call step</b>.</li>
</ol>

Do this before and after <b>call step</b>:

~~~
c parameter test
        if( phys )then
             print *,jst, nact, lprop, prop, nbplot, dispy,
     +                   lglen, alspi, jlen, besc, nLbin, nLa,
     +                   lzman, zman, lzpr, zpbin, lmoni, ehmon,
     +                   nwring, wring, llz, Lzval
        end if
~~~

This is impossible because parameters are not declared. So we need global variables to read them out.

in step.f,
>integer m_sp
>parameter(m_sp=1000000)  
>real*8 mang(m_sp), mpe(m_sp), mte(m_sp)  
>common /myanls/ mang, mpe, nmax