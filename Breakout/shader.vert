#version 330 core

layout(location = 0) in vec3 inPosition;

uniform mat4 projectionMatrix;
uniform vec2 position;
uniform vec2 scale;

void main()
{
    gl_Position = vec4( inPosition, 1 );
    //gl_Position = projectionMatrix * vec4( (inPosition + position) * scale, 2.0f, 1.0f );
}

