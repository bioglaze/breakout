#version 330 core

layout(location = 0) in vec3 inPosition;

uniform mat4 projectionMatrix;
uniform vec2 position;
uniform vec2 scale;

void main()
{
    gl_Position = vec4( inPosition, 1.0 );
    //gl_Position = projectionMatrix * vec4( inPosition.xy * vec2( 5, 5 ) + vec2( 20, 20 ) /*+ position*/, 0.0/*inPosition.z*/, 1.0 );
}

