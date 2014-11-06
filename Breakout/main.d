module main;

import std.stdio;
import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

void main(string[] args)
{
	DerelictSDL2.load();
	SDL_Init( SDL_INIT_VIDEO );
	SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, 16);
	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
	SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 0);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

	auto win = SDL_CreateWindow("Breakout", SDL_WINDOWPOS_CENTERED,
	                    SDL_WINDOWPOS_CENTERED, 640, 480, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
	DerelictGL3.load();
	auto context = SDL_GL_CreateContext( win );
	DerelictGL3.reload();

	//string vendor = to!string(glGetString(GL_VENDOR));
	writefln("Vendor:   %s",   glGetString(GL_VENDOR));
	writefln("Renderer: %s",   glGetString(GL_RENDERER));
	writefln("Version:  %s",   glGetString(GL_VERSION));
	writefln("GLSL:     %s\n", glGetString(GL_SHADING_LANGUAGE_VERSION));

	SDL_GL_SetSwapInterval( 1 );

	bool quit = false;

	while (!quit)
	{
		glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
		SDL_GL_SwapWindow( win );
	}
}

