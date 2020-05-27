/**
 * Breakout game
 * 
 * Written by Timo Wiren (http://twiren.kapsi.fi)
 * Date: 2014-11-12
 */
module main;

import std.stdio;
import std.conv;
import bindbc.sdl;
import bindbc.opengl;
import shader;
import game;

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

void GenerateQuadBuffers( ref GLuint vao, ref GLuint vbo )
{
	glGenVertexArrays( 1, &vao );
	glBindVertexArray( vao );

	float[] quad = [ 0, 0, 0, 1, 1, 0, 1, 0, 1, 1, 0, 1 ];

	glGenBuffers( 1, &vbo );
	glBindBuffer( GL_ARRAY_BUFFER, vbo );
	glBufferData( GL_ARRAY_BUFFER, quad.length * GLfloat.sizeof, quad.ptr, GL_STATIC_DRAW );
	glEnableVertexAttribArray( 0 );
	glVertexAttribPointer( 0, 2, GL_FLOAT, GL_FALSE, 0, null );
	CheckGLError("GenerateQuadBuffers end");
}

void main( string[] args )
{
	const int screenWidth = 640;
	const int screenHeight = 480;

	SDLSupport ret = loadSDL();

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

	auto context = SDL_GL_CreateContext( win );

	if (!context)
	{
		throw new Error( "Failed to create GL context!" );
	}

        GLSupport re = loadOpenGL();
        
	SDL_GL_SetSwapInterval( 1 );

	GLuint vao;
	GLuint vbo;
	GenerateQuadBuffers( vao, vbo );

	Shader gshader = new Shader();
	gshader.Load( "Breakout/shader.vert", "Breakout/shader.frag" );
	gshader.Use();
	float[] projection;
	MakeProjectionMatrix( 0, screenWidth, screenHeight, 0, -1, 1, projection );
	gshader.SetMatrix44( "projectionMatrix", projection );

	bool quit = false;

	Game game = new Game( gshader, screenWidth, screenHeight );
	game.SetPaddle( 0, screenHeight - 100 );
	game.SetBall( screenWidth / 2, screenHeight / 2 );
	const float paddleSpeed = 600;

	Uint32 lastTick = SDL_GetTicks();

	while (!quit)
	{
		float deltaTime = (SDL_GetTicks() - lastTick) / 1000.0f;

		lastTick = SDL_GetTicks();
		SDL_Event e;
		const Uint8* keyState = SDL_GetKeyboardState( null );    

		if (keyState[ SDL_SCANCODE_RIGHT ] == 1)
		{
			game.Start();
			game.MoveHoriz( paddleSpeed * deltaTime );
		}

		if (keyState[ SDL_SCANCODE_LEFT ] == 1)
		{
			game.MoveHoriz( -paddleSpeed * deltaTime );
		}

		if (keyState[ SDL_SCANCODE_ESCAPE ] == 1)
		{
			quit = true;
		}

		while (SDL_PollEvent( &e ))
		{
			if (e.type == SDL_WINDOWEVENT)
			{
				if (e.window.event == SDL_WINDOWEVENT_CLOSE)
				{
					quit = true;
				}
			}
		}

		glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
		game.Simulate();
		game.Draw();
		CheckGLError("Before swap");
		SDL_GL_SwapWindow( win );
	}

	glDeleteBuffers( 1, &vbo );
	glDeleteVertexArrays( 1, &vao );
	gshader.Delete();

	SDL_DestroyWindow( win );
	SDL_Quit();
}

