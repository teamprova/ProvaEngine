module prova.util.dynamicarray;

/**
 * Removes an element in place and returns the shortened range using
 * std.algorithm's countUntil and remove functions 
 */
T[] removeElement(T)(T[] array, T element) {
  import std.algorithm : countUntil, remove;

  auto index = array.countUntil(element);
  return array.remove(index);
}
