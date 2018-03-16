module prova.legal;

/// array of legal disclaimers, must be included in any projects that use ProvaEngine
string[] disclaimers = [
  "Portions of this software are copyright © 2018 The FreeType Project (www.freetype.org).  All rights reserved.",
];

/// returns a formatted list of disclaimers
string formatDisclaimers(int columns)
{
  import std.string;

  return disclaimers.join("\n").wrap(columns);
}