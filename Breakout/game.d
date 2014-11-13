module game;
import derelict.opengl3.gl3;
import shader;
import std.random;
import std.stdio;

struct Vec2(T)
{
	T x;
	T y;
}

struct Block
{
	Vec2!int position;
	bool alive = true;
}

void DrawQuad( Shader shader, float x, float y, float width, float height )
{
	shader.SetFloat2( "position", x, y );
	shader.SetFloat2( "scale", width, height );
	glDrawArrays( GL_TRIANGLES, 0, 6 );
}

class Game
{
	this( Shader aShader, int aScreenWidth, int aSreenHeight )
	{
		shader = aShader;
		screenSize.x = aScreenWidth;
		screenSize.y = aSreenHeight;
		InitBlocks();
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

	public void Start()
	{
		if (running)
		{
			return;
		}

		running = true;
		auto rnd = uniform( 2.0f, 2.5f );
		ballDirection.x = rnd;
		ballDirection.y = rnd;
	}

	public void Simulate()
	{
		if (IsGameOver())
		{
			Reset();
		}

		if (!running)
		{
			return;
		}

		ballPos.x += ballDirection.x;
		ballPos.y += ballDirection.y;

		if (ballPos.y + ballSize.y >= screenSize.y)
		{
			playerDead = true;
			running = false;
			return;
		}

		if (ballPos.x <= 0 || ballPos.x + ballSize.x >= screenSize.x)
		{
			ballDirection.x = -ballDirection.x;
		}

		if (ballPos.y <= 0 || ballPos.y + ballSize.y >= screenSize.y || BallCollidesWithPaddle())
		{
			ballDirection.y = -ballDirection.y;
		}

		for (int i = 0; i < blocks.length; ++i)
		{
			bool xHits = ballPos.x > blocks[ i ].position.x && ballPos.x < blocks[ i ].position.x + blockSize.x + ballSize.x;
			bool yHits = ballPos.y + ballSize.y > blocks[ i ].position.y && ballPos.y < blocks[ i ].position.y + blockSize.y;

			if (xHits && yHits && blocks[ i ].alive)
			{
				blocks[ i ].alive = false;
				ballDirection.y = -ballDirection.y;
			}
		}
	}

	public void MoveHoriz( float amount )
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
		DrawQuad( shader, ballPos.x, ballPos.y, ballSize.x, ballSize.y );
		DrawBlocks();
	}

	private pure bool BallCollidesWithPaddle()
	{
		float xInside = ballPos.x > paddlePos.x - 20 && ballPos.x < paddlePos.x + paddleWidth + 20;
		float yInside = ballPos.y > paddlePos.y - 20 && ballPos.y < paddlePos.y + 20;
		return xInside && yInside;
	}

	private void InitBlocks()
	{
		for (int y = 0; y < 5; ++y)
		{
			for (int x = 0; x < 10; ++x)
			{
				blocks[ y * 10 + x ].position.x = 70 + x * 50;
				blocks[ y * 10 + x ].position.y = 50 + y * 30;
			}
		}
	}

	private void DrawBlocks()
	{
		for (int i = 0; i < blocks.length; ++i)
		{
			if (blocks[ i ].alive)
			{
				DrawQuad( shader, blocks[ i ].position.x, blocks[ i ].position.y, blockSize.x, blockSize.y );
			}
		}
	}

	private void Reset()
	{
		ballDirection.x = -2;
		ballDirection.y = 2;
		paddlePos.x = 10;
		paddlePos.y = screenSize.y - 100;
		SetBall( screenSize.x / 2, screenSize.y / 2 );

		running = false;
		playerDead = false;

		for (int i = 0; i < blocks.length; ++i)
		{
			blocks[ i ].alive = true;
		}
	}

	private bool IsGameOver()
	{
		if (playerDead)
		{
			return true;
		}

		for (int i = 0; i < blocks.length; ++i)
		{
			if (blocks[ i ].alive)
			{
				return false;
			}
		}

		return true;
	}

	private int paddleWidth = 100;
	private Shader shader;
	private Vec2!int ballSize = { 20, 20 };
	private Vec2!float ballPos;
	private Vec2!float ballDirection = { -2, 2 };
	private Vec2!int screenSize;
	private Vec2!float paddlePos;
	private Block[5 * 10] blocks;
	private Vec2!int blockSize = { 40, 20 };
	private bool running = false;
	private bool playerDead = false;
}

