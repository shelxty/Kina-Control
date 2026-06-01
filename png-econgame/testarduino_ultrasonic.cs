using Godot;
using System;
using System.IO.Ports;

public partial class testarduino_ultrasonic : Node2D // edit the class "testarduino_ultrasonic" to be whatever you saved the scene.tscn as (not the name of the root node2d) or you'll get an error
{
	SerialPort serialPort; 
	RichTextLabel text; 

	public override void _Ready()
	{
		// Match this to your exact scene tree node name
		text = GetNode<RichTextLabel>("RichTextLabel"); 
		
		serialPort = new SerialPort(); 
		serialPort.PortName = "COM4"; // Remember to change this to your actual port!
		serialPort.BaudRate = 9600; 
		serialPort.ReadTimeout = 50; // Prevents the game from freezing if data is incomplete
		
		try
		{
			serialPort.Open();
		}
		catch (Exception e)
		{
			GD.PrintErr($"Could not open serial port: {e.Message}");
		}
	}

	public override void _Process(double delta)
	{
		if (serialPort == null || !serialPort.IsOpen) return;

		// Process all incoming complete lines
		while (serialPort.BytesToRead > 0)
		{
			try
			{
				// Read the complete line up to the newline character and strip spaces
				string rawMessage = serialPort.ReadLine().Trim();
				
				// Split the message at the comma: index 0 is status, index 1 is distance
				string[] dataTokens = rawMessage.Split(',');

				if (dataTokens.Length == 2)
				{
					string pathStatus = dataTokens[0];
					string distanceValue = dataTokens[1];

					// Format and output the text directly to your RichTextLabel
					if (pathStatus == "CLEAR")
					{
						text.Text = $"Path is clear. Nearest object is {distanceValue} cm away.";
					}
					else if (pathStatus == "BLOCKED")
					{
						text.Text = $"Path is NOT clear! Nearest object is {distanceValue} cm away.";
					}
				}
			}
			catch (TimeoutException)
			{
				// Normal behavior: caught if ReadLine reaches the time limit before finding a \n
			}
			catch (Exception e)
			{
				GD.PrintErr($"Error parsing serial data: {e.Message}");
			}
		}
	}

	public override void _ExitTree()
	{
		if (serialPort != null && serialPort.IsOpen)
		{
			serialPort.Close();
		}
	}
}
