Grdfld
----
<dl>
<dt>grdfld(i, itype)</dt>
<dd>Gravitational Potential at a P3D grid field point:</dd>
<dd>
<li>i = grid point in mesh(jgrid);</li>
<li>itype = 1, radial force</li>
<li>itype = 2, azimuthal force</li>
<li>itype = 3, vertical force</li>
<li>itype = 4, potential</li>
</dd>
</dl>

Potgrd
----
<dl>
<dt>potgrd.f</dt>
<dd>returns potential on the grid at arbitrary field point by computing the work required from the centre. The work required is determined by computing a line integral of the grid force starting from centre and moving outward in directions parallel to the mesh axes. </dd>
</dl>