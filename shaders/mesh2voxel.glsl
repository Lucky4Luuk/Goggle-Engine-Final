#define voxelSize 0.1

struct Triangle
{
  vec3 one;
  vec3 two;
  vec3 three;
};

uniform Triangle tris[3000];
uniform float texSize;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec3 voxels[3000];

  vec2 uv = vec2(0.0);
  uv.x = screen_coords.x / texSize;
  uv.y = screen_coords.y / texSize;

  vec3 pos = vec3(0.0);
  pos.x = uv.x * texSize;
  pos.y = floor(uv.y * texSize) / texSize;
  pos.z = mod(uv.y * texSize, texSize);

  pos.x /= texSize;
  pos.y /= texSize;
  pos.z /= texSize;

  int index = 0;

  for (int i=0; i<3000; i++)
  {
    vec3 dir1 = normalize(tris[i].two - tris[i].one);
    vec3 dir2 = normalize(tris[i].three - tris[i].two);
    vec3 dir3 = normalize(tris[i].one - tris[i].three);
    float l1 = distance(tris[i].two, tris[i].one);
    float l2 = distance(tris[i].three, tris[i].two);
    float l3 = distance(tris[i].one, tris[i].three);


    for (int j=0; j<50; j++)
    {
      if (length(dir1*j*voxelSize) > l1) break;
      vec3 p = floor(tris[i].one + dir1*j*voxelSize);
      voxels[index] = p;
      index += 1;
    }

    for (int j=0; j<50; j++)
    {
      if (length(dir2*j*voxelSize) > l2) break;
      vec3 p = floor(tris[i].two + dir2*j*voxelSize);
      voxels[index] = p;
      index += 1;
    }

    for (int j=0; j<50; j++)
    {
      if (length(dir3*j*voxelSize) > l3) break;
      vec3 p = floor(tris[i].three + dir3*j*voxelSize);
      voxels[index] = p;
      index += 1;
    }
  }

  float d = distance(pos, voxels[0]);

  for (int i=0; i<3000; i++)
  {
    if (i > index) break;
    d = min(d, distance(pos, voxels[i]));
  }

  vec4 col = vec4(d, d, d, 1.0);

  return col;
}
