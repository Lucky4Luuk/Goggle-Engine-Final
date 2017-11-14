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

float L_udTriangle(vec3 p, vec3 a, vec3 b, vec3 c)
{
  vec3 abc = (a + b + c) / 3;
  return distance(abc, p);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec2 uv = vec2(0.0);
  //uv.x = screen_coords.x / texSize;
  //uv.y = screen_coords.y / (texSize*texSize);
  uv = texture_coords;

  vec3 pos = vec3(0.0);
  pos.x = uv.x * texSize;
  pos.y = floor(uv.y * texSize);
  pos.z = mod(uv.y * texSize, 1.0) * texSize;

  // pos.x /= texSize;
  // pos.y /= texSize;
  // pos.z /= texSize;

  float d = udTriangle(pos, Texel(mesh, vec2(0.0, 0.0)).rgb * texSize, Texel(mesh, vec2(1.0, 0.0)).rgb * texSize, Texel(mesh, vec2(2.0, 0.0)).rgb * texSize);

  for (int y=0; y<meshres.y; y++)
  {
    for (int x=0; x<meshres.x; x+=3)
    {
      vec3 pos_one = Texel(mesh, vec2(float(x), float(y))).rgb * texSize;
      vec3 pos_two = Texel(mesh, vec2(float(x+1), float(y))).rgb * texSize;
      vec3 pos_three = Texel(mesh, vec2(float(x+2), float(y))).rgb * texSize;
      d = min(d, udTriangle(pos, pos_one, pos_two, pos_three));
    }
  }

  d = floor(d*15.0)/15.0;

  d /= texSize;

  vec4 col = vec4(d, d, d, 1.0);

  // vec4 col = vec4(pos, 1.0);
  // col.rb = vec2(0.0);

  //Triangles are done by having 3 pixels per triangle. That's why the image is 126x126, not 128x128.
  return col;
}
