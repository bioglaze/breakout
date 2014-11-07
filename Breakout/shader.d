module shader;
import std.exception;
import std.file;
import std.stdio;
import std.string;
import derelict.opengl3.gl3;

class Shader
{
	public void Load( string vertexPath, string fragmentPath )
	{
		try
		{
			Compile( ReadFile( vertexPath ), GL_VERTEX_SHADER );
			Compile( ReadFile( fragmentPath ), GL_FRAGMENT_SHADER );
			program = glCreateProgram();
			Link();
		}
		catch (Exception e)
		{
			writeln( "Could not open " ~ vertexPath ~ " or " ~ fragmentPath );
		}
	}

	public void SetFloat( string name, float value )
	{
		immutable char* nameCstr = toStringz( name );
		glUniform1f( glGetUniformLocation( program, nameCstr ), value );
	}

	private void Link()
	{
		glLinkProgram( program );
		PrintInfoLog( program, GL_LINK_STATUS );
	}

	private void PrintInfoLog( GLuint shader, GLenum status )
	{
		assert( status == GL_LINK_STATUS || status == GL_COMPILE_STATUS, "Wrong status!" );

		GLint shaderCompiled = GL_FALSE;
		glGetShaderiv( shader, status, &shaderCompiled );
		
		if (shaderCompiled != GL_TRUE)
		{
			int infoLogLength = 0;
			int maxLength = infoLogLength;
			
			glGetProgramiv( program, GL_INFO_LOG_LENGTH, &maxLength );
			char[] infoLog = new char[ maxLength + 1 ];
			
			glGetProgramInfoLog( program, maxLength, &infoLogLength, &infoLog[ 0 ] );
			
			if (infoLogLength > 0)
			{
				writeln( infoLog );
			}
		}
	}

	private void Compile( string source, GLenum shaderType )
	{
		assert( shaderType == GL_VERTEX_SHADER || shaderType == GL_FRAGMENT_SHADER, "Wrong shader type!" );

		immutable char* sourceCstr = toStringz( source );
		GLuint shader = glCreateShader( shaderType );
		glShaderSource( shader, 1, &sourceCstr, null );
		glCompileShader( shader );
		PrintInfoLog( shader, GL_COMPILE_STATUS );
	}

	private string ReadFile( string path )
	{
		auto inFile = File( path, "r" );
		string outContents;

		while (!inFile.eof())
		{
			string line = inFile.readln();
			outContents ~= line;
		}

		return outContents;
	}

	private GLuint program;
}

