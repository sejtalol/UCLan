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

Solution
----
in galaxy.f, step.f, anlgrp.f, create common blocks  

>integer m_sp  
>parameter(m_sp=1000000) 
>real*8 mang(m_sp), mpe(m_sp), mte(m_sp)  
>common /myanls/ mang, mpe, mte  

This records angular momentum (for double check), potential energy (also with some extra contribution), and total energy (potential energy + kinetic energy)  

The actual location of each particle is recorded by array <b>loc( is ) = inext</b>. Therefore the position of each particle in the buffer should be <b>j = loc(is) / nwpp + 1 </b>th particle in the ptcls array.  

Therefore we have the <b>position (ptcls(inext + i), i = 1, 3)</b>, <b>velocity (ptcls(inext + i), i = 4, 6)</b>, and the <b>mass weight pwt(is) = ptcls(inext + 7)</b>. <b>nwpp</b> should be length of each record = 7.  

The routine is written in anlgrp.f, also initialize each potential array at step.f.  

Do we need to write down the position and velocity at each step? No! 

Still needs to do
------
<ol>
	<li>Fortran output file: revised to wrtie in loop</li>
	<li>phys or without phys</li>
</ol>