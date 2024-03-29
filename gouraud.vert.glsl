# version 120 
/*
 * Michael Shafae
 * mshafae at fullerton.edu
 * 
 * A simple Blinn-Phong shader with two light sources.
 * This file is the vertex shader which transforms the
 * input vertex into eye coordinates and passes along
 * the vertex's color and normal to the fragment shader.
 *
 * For more information see:
 *     <http://en.wikipedia.org/wiki/Blinn–Phong_shading_model>
 *
 * $Id: blinn_phong.vert.glsl 4891 2014-04-05 08:36:23Z mshafae $
 *
 * Be aware that for this course, we are limiting ourselves to
 * GLSL v.1.2. This is not at all the contemporary shading
 * programming environment, but it offers the greatest degree
 * of compatability.
 *
 * Please do not use syntax from GLSL > 1.2 for any homework
 * submission.
 *
 */

// These are passed in from the CPU program, camera_control_*.cpp
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat4 normalMatrix;
uniform vec4 light0_position;
uniform vec4 light0_color;
uniform vec4 light1_position;
uniform vec4 light1_color;


// These are variables that we wish to send to our fragment shader
// In later versions of GLSL, these are 'out' variables.
//varying vec3 myNormal;
//varying vec4 myVertex;
varying vec4 myColor;

vec4 ComputeLight (const in vec3 direction, const in vec4 lightcolor, const in vec3 normal, const in vec3 viewer, const in vec4 mydiffuse, const in vec4 myspecular, const in float myshininess){

  float nDotL = dot(normal, direction);
  vec4 lambert = mydiffuse * lightcolor * max (nDotL, 0.0);

  //float nDotH = dot(normal, halfvec);
  vec3 reflection = reflect(normal, direction);
  float vDotR = dot(viewer, reflection);
  //vec4 phong = myspecular * lightcolor * pow (max(nDotH, 0.0), myshininess);
  vec4 phong = myspecular * lightcolor * pow (max(vDotR, 0.0), myshininess);

  vec4 retval = lambert + phong;
  return retval;
}

void main() {
  vec4 ambient = vec4(0.2, 0.2, 0.2, 1.0);
  vec4 diffuse = vec4(0.5, 0.5, 0.5, 1.0);
  vec4 specular = vec4(1.0, 1.0, 1.0, 1.0);
  float shininess = 100;

  gl_Position = projectionMatrix * modelViewMatrix * gl_Vertex;

  // They eye is always at (0,0,0) looking down -z axis 
  // Also compute current fragment position and direction to eye 

  vec4 myVertex = gl_Vertex;
  vec3 myNormal = gl_Normal;

  const vec3 eyepos = vec3(0,0,0);
  vec4 _mypos = modelViewMatrix * myVertex;
  vec3 mypos = _mypos.xyz / _mypos.w;
  vec3 eyedirn = normalize(eyepos - mypos);

  // Compute normal, needed for shading. 
  vec4 _normal = normalMatrix * vec4(myNormal, 0.0);
  vec3 normal = normalize(_normal.xyz);

  // Light 0, point
  vec3 position0 = light0_position.xyz / light0_position.w;
  vec3 direction0 = normalize (position0 - mypos);
  //vec3 half0 = normalize(direction0 + eyedirn); 
  vec3 viewer0 = eyedirn;
  vec4 color0 = ComputeLight(direction0, light0_color, normal, viewer0, diffuse, specular, shininess) ;

  // Light 1, point 
  vec3 position1 = light1_position.xyz / light1_position.w;
  vec3 direction1 = normalize(position1 - mypos);
  //vec3 half1 = normalize(direction1 + eyedirn);
  vec3 viewer1 = eyedirn;
  vec4 color1 = ComputeLight(direction1, light1_color, normal, viewer1, diffuse, specular, shininess) ;

  myColor = ambient + color0 + color1;

}
