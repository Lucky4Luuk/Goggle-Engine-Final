// Mesh to SDF shader

uniform Image mesh;
uniform vec2 meshres;
uniform float texSize;

float dot2( in vec3 v ) { return dot(v,v); }
float udTriangle( vec3 p, vec3 a, vec3 b, vec3 c )
{
    vec3 ba = b - a; vec3 pa = p - a;
    vec3 cb = c - b; vec3 pb = p - b;
    vec3 ac = a - c; vec3 pc = p - c;
    vec3 nor = cross( ba, ac );

    return sqrt(
    (sign(dot(cross(ba,nor),pa)) +
     sign(dot(cross(cb,nor),pb)) +
     sign(dot(cross(ac,nor),pc))<2.0)
     ?
     min( min(
     dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
     dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
     dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.0,1.0)-pc) )
     :
     dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec2 uv = vec2(0.0);
  uv.x = screen_coords.x / texSize;
  uv.y = screen_coords.y / texSize;

  vec3 pos = vec3(0.0);
  pos.x = uv.x;
  pos.y = mod(uv.y,1.0);
  pos.z = uv.y / texSize;

  float d = udTriangle(pos, Texel(mesh, vec2(0.0, 0.0)).xyz, Texel(mesh, vec2(1.0, 0.0)).xyz, Texel(mesh, vec2(2.0, 0.0)).xyz);

  for (int y=0; y<meshres.y; y++)
  {
    for (int x=3; x<meshres.x; x+=3)
    {
      vec3 pos_one = Texel(mesh, vec2(float(x), float(y))).xyz;
      vec3 pos_two = Texel(mesh, vec2(float(x+1), float(y))).xyz;
      vec3 pos_three = Texel(mesh, vec2(float(x+2), float(y))).xyz;
      d = min(d, udTriangle(pos, pos_one, pos_two, pos_three));
    }
  }

  vec4 col = vec4(d, 1.0, 1.0, 1.0);

  //Triangles are done by having 3 pixels per triangle. That's why the image is 126x126, not 128x128.
  return col;
}
