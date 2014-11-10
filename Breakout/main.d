module main;

import std.stdio;
import std.conv;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import shader;

//float[] vertices = [ -1, -1, -1, 1, 1, -1, 1, -1, 1, 1, -1, 1 ];
GLuint vao;
GLuint vbo;

void CheckGLError( string info )
{
	GLenum errorCode = GL_INVALID_ENUM;
	
	while ((errorCode = glGetError()) != GL_NO_ERROR)
	{
		writeln( "OpenGL error in " ~ info ~ ": " ~ to!string(errorCode) );
	}
}

void MakeProjectionMatrix( float left, float right, float bottom, float top, float nearDepth, float farDepth, out float[] matrix )
{
    float tx = -((right + left) / (right - left));
    float ty = -((top + bottom) / (top - bottom));
    float tz = -((farDepth + nearDepth) / (farDepth - nearDepth));
	
    matrix =
	[
        2.0f / (right - left), 0.0f, 0.0f, 0.0f,
        0.0f, 2.0f / (top - bottom), 0.0f, 0.0f,
        0.0f, 0.0f, -2.0f / (farDepth - nearDepth), 0.0f,
        tx, ty, tz, 1.0f
	];
}

void GenerateQuadBuffers()
{
	glGenVertexArrays( 1, &vao );
	glBindVertexArray( vao );

	float[] triangle = [ 
		-1.0f, -1.0f, 0.0f,
		1.0f, -1.0f, 0.0f,
		0.0f,  1.0f, 0.0f
	];

	glGenBuffers( 1, &vbo );
	glBindBuffer( GL_ARRAY_BUFFER, vbo );
	glBufferData( GL_ARRAY_BUFFER, triangle.length * GLfloat.sizeof, &triangle[0], GL_STATIC_DRAW );
	glEnableVertexAttribArray( 0 );
	glVertexAttribPointer( 0, 3, GL_FLOAT, GL_FALSE, 0, null );
	CheckGLError("GenerateQuadBuffers end");
}

void DrawQuad( Shader shader, float x, float y, float width, float height )
{
	shader.SetFloat2( "position", x, y );
	//shader.SetFloat2( "scale", width, height );
	glDrawArrays( GL_TRIANGLES, 0, 3 );
}

void main(string[] args)
{
	const int screenWidth = 640;
	const int screenHeight = 480;

	DerelictSDL2.load();

	if (SDL_Init( SDL_INIT_EVERYTHING ) < 0)
	{
		throw new Error( "Failed to initialze SDL: " ~ to!string( SDL_GetError() ) );
	}

	SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE, 24 );
	SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 3 );
	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 3 );
	SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );

	auto win = SDL_CreateWindow("Breakout", SDL_WINDOWPOS_CENTERED,
	                    SDL_WINDOWPOS_CENTERED, screenWidth, screenHeight, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
	DerelictGL3.load();
	auto context = SDL_GL_CreateContext( win );

	if (!context)
	{
		throw new Error( "Failed to create GL context!" );
	}

	DerelictGL3.reload();

	writefln("Vendor:   %s",   to!string( glGetString( GL_VENDOR ) ) );
	writefln("Renderer: %s",   to!string( glGetString( GL_RENDERER ) ) );
	writefln("Version:  %s",   to!string( glGetString( GL_VERSION ) ) );
	writefln("GLSL:     %s\n", to!string( glGetString( GL_SHADING_LANGUAGE_VERSION ) ) );

	SDL_GL_SetSwapInterval( 1 );

	float[] projection;
	MakeProjectionMatrix( 0, screenWidth, 0, screenHeight, 1, 100, projection );

	GenerateQuadBuffers();
	Shader gshader = new Shader();
	gshader.Load( "shader.vert", "shader.frag" );
	gshader.Use();
	gshader.SetMatrix44( "projectionMatrix", projection );

	bool quit = false;
	SDL_Event event;

	while (!quit)
	{
		while( SDL_PollEvent( &event ) != 0 )
		{
			if (event.type == SDL_QUIT)
			{
				quit = true;
			}
			else if (event.type == SDL_KEYDOWN)
			{
				switch( event.key.keysym.sym )
				{
					case SDLK_ESCAPE:
						quit = true;
						break;

					case SDLK_UP:
						writeln("up");
						break;
						
					case SDLK_DOWN:
						writeln("down");
						break;
						
					case SDLK_LEFT:
						writeln("left");
						break;
						
					case SDLK_RIGHT:
						writeln("right");
						break;
						
					default:
						break;
				}
			}
		}

		glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
		DrawQuad( gshader, 10, -10, 10, 10 );
		CheckGLError("Before swap");
		SDL_GL_SwapWindow( win );
	}

	glDeleteBuffers( 1, &vbo );
	glDeleteVertexArrays( 1, &vao );

	SDL_DestroyWindow( win );
	SDL_Quit();
}

