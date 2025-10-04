extends Node

signal onPrint(message : String, color : Color)

const defaultColor : Color = Color("ffffff");
const logColor : Color = Color("738aff");
const warningColor : Color = Color("ffd994");
const errorColor : Color = Color("ff738a");
const successColor : Color = Color("73ff8a");

func print(...args : Array[Variant]) -> void:
	printColor(defaultColor, args);
func log(...args : Array[Variant]) -> void:
	printColor(logColor, args);
func printWarning(...args : Array[Variant]) -> void:
	printRaw(warningColor, args);
func printError(...args : Array[Variant]) -> void:
	printRaw(errorColor, args);
func printSuccess(...args : Array[Variant]) -> void:
	printRaw(successColor, args);
	
func printColor(color : Color, args : Array[Variant]) -> void:
	printRaw(color, args);

func printRaw(color : Color, args : Array[Variant]):
	# Convert args to string.
	var message : String = "%s".repeat(args.size()).strip_edges() % args;
	# Send signal.
	onPrint.emit(message, color);
	# Print string.
	print_rich("[color="+color.to_html()+"]", message, "[/color]")
