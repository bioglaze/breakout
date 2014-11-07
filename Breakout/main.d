module main;

import std.stdio;
import std.conv;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;
import shader;

void main(string[] args)
{
	DerelictSDL2.load();
	SDL_Init( SDL_INIT_VIDEO );
	SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, 16);
	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
	SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 0);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION, 3 );
	SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION, 3 );
	SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE );

	auto win = SDL_CreateWindow("Breakout", SDL_WINDOWPOS_CENTERED,
	                    SDL_WINDOWPOS_CENTERED, 640, 480, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
	DerelictGL3.load();
	auto context = SDL_GL_CreateContext( win );
	DerelictGL3.reload();

	writefln("Vendor:   %s",   to!string( glGetString( GL_VENDOR ) ) );
	writefln("Renderer: %s",   to!string( glGetString( GL_RENDERER ) ) );
	writefln("Version:  %s",   to!string( glGetString( GL_VERSION ) ) );
	writefln("GLSL:     %s\n", to!string( glGetString( GL_SHADING_LANGUAGE_VERSION ) ) );

	SDL_GL_SetSwapInterval( 1 );

	Shader shader = new Shader;
	shader.Load( "shader.vert", "shader.frag" );

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
		SDL_GL_SwapWindow( win );
	}
}

