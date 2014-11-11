/**
 * Breakout game
 * 
 * Written by Timo Wiren (http://twiren.kapsi.fi)
 * Date: 2014-11-10
 */
module main;

import std.stdio;
import std.conv;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import shader;

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

void DrawQuad( Shader shader, float x, float y, float width, float height )
{
	shader.SetFloat2( "position", x, y );
	shader.SetFloat2( "scale", width, height );
	glDrawArrays( GL_TRIANGLES, 0, 6 );
}

struct Vec2(T)
{
	T x;
	T y;
}

class Game
{
	this( Shader aShader, int aScreenWidth, int aSreenHeight )
	{
		shader = aShader;
		screenSize.x = aScreenWidth;
		screenSize.y = aSreenHeight;
		ballDirection.x = 0;
		ballDirection.y = 0.2f;
	}

	public void SetPaddle( int x, int y )
	{
		paddlePos.x = x;
		paddlePos.y = y;
	}

	public void SetBall( int x, int y )
	{
		ballPos.x = x;
		ballPos.y = y;
	}

	public void Simulate()
	{
		ballPos.x += ballDirection.x;
		ballPos.y += ballDirection.y;
	}

	public void MoveHoriz( int amount )
	{
		bool rightOk = amount > 0 && paddlePos.x + paddleWidth < screenSize.x;
		bool leftOk = amount < 0 && paddlePos.x > 0;

		if (rightOk || leftOk)
		{
			paddlePos.x += amount;
		}
	}

	public void Draw()
	{
		DrawQuad( shader, paddlePos.x, paddlePos.y, paddleWidth, 20 );
		DrawQuad( shader, ballPos.x, ballPos.y, 20, 20 );
	}

	private int paddleWidth = 100;
	private Shader shader;
	private Vec2!float ballPos;
	private Vec2!float ballDirection;
	private Vec2!int screenSize;
	private Vec2!int paddlePos;
}

void main( string[] args )
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

	SDL_GL_SetSwapInterval( 1 );

	GLuint vao;
	GLuint vbo;
	GenerateQuadBuffers( vao, vbo );

	Shader gshader = new Shader();
	gshader.Load( "shader.vert", "shader.frag" );
	gshader.Use();
	float[] projection;
	MakeProjectionMatrix( 0, screenWidth, screenHeight, 0, -1, 1, projection );
	gshader.SetMatrix44( "projectionMatrix", projection );

	bool quit = false;

	Game game = new Game( gshader, screenWidth, screenHeight );
	game.SetPaddle( 0, screenHeight - 100 );
	game.SetBall( screenWidth / 2, screenHeight / 2 );
	const int paddleSpeed = 20;

	while (!quit)
	{
		SDL_Event event;

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
						game.MoveHoriz( -paddleSpeed );
						break;
						
					case SDLK_RIGHT:
						game.MoveHoriz( paddleSpeed );
						break;
						
					default:
						break;
				}
			}
		}

		glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
		//DrawQuad( gshader, 10, 10, 50, 50 );
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

