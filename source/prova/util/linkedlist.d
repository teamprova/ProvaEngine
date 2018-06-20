module prova.util.linkedlist;

import std.typecons;

/**
 * Linked list node
 */
class Node(T)
{
  private LinkedList!T list;
  private Node!T next;
  private Node!T last;
  private Nullable!T _value;

  /**
   * Retrieves the stored value
   */
  @property T value()
  {
    return _value;
  }

  /**
   * Modifies the stored value
   */
  @property void value(T value)
  {
    _value = value;
  }

  /**
   * Gets the node previous in order
   */
  Node!T getLast()
  {
    return last;
  }

  /**
   * Gets the node next in order
   */
  Node!T getNext()
  {
    return next;
  }

  /**
   * Detaches the node from the list
   */
  void remove()
  {
    if(last)
      last.next = next;

    if(next)
      next.last = last;

    if(list.last == this)
      list.last = null;

    if(list.first == this)
      list.first = null;

    list.count--;
  }
}

/**
  * LinkedList template
  */
class LinkedList(T)
{
  private Node!T first;
  private Node!T last;
  private int count = 0;

  /**
    * Returns the node count
    */
  @property int length()
  {
    return count;
  }

  ///
  Node!T getFirstNode()
  {
    return first;
  }

  ///
  Node!T getLastNode()
  {
    return last;
  }

  /**
    * Creates a node and places it at the start of the list
    */
  Node!T insertFront(T value)
  {
    return insertBefore(value, first);
  }

  /**
    * Creates a node and places it at the end of the list
    */
  Node!T insertBack(T value)
  {
    return insertAfter(value, last);
  }

  /**
    * Creates a node in the list placed before the specified node
    */
  Node!T insertBefore(T value, Node!T node)
  {
    if(!node && first)
      return insertBefore(value, first);

    Node!T storedNode = new Node!T;
    storedNode.value = value;
    storedNode.list = this;

    if(node) {
      storedNode.last = node.last;
      node.last = storedNode;
      storedNode.next = node;
    } else {
      first = last = storedNode;
    }

    if(storedNode.last)
      storedNode.last.next = storedNode;

    count++;
    return storedNode;
  }

  /**
    * Creates a node in the list placed after the specified node
    */
  Node!T insertAfter(T value, Node!T node)
  {
    if(!node && last)
      return insertAfter(value, last);

    Node!T storedNode = new Node!T;
    storedNode.value = value;
    storedNode.list = this;

    if(node) {
      storedNode.next = node.next;
      node.next = storedNode;
      storedNode.last = node;
    } else {
      first = last = storedNode;
    }

    if(storedNode.next)
      storedNode.next.last = storedNode;

    count++;
    return storedNode;
  }

  /**
    * Tests if the list contains a node with the specified value
    */
  bool contains(T value)
  {
    foreach(Node!T node; this)
      if(node.value == value)
        return true;

    return false;
  }

  /**
    * Removes the first node with the specified value
    */
  void remove(T value)
  {
    foreach(Node!T node; this) {
      if(node.value == value) {
        node.remove();
        break;
      }
    }
  }

  /**
    * Empties the LinkedList
    */
  void clear()
  {
    first = null;
    last = null;
    count = 0;
  }

  int opApply(int delegate(Node!T result) dg)
  {
    int result = 0;

    for(Node!T node = first; node; node = node.next) {
      result = dg(node);

      if(result)
        break;
    }

    return result;
  }

  int opApply(int delegate(ref T result) dg)
  {
    int result = 0;

    for(Node!T node = first; node; node = node.next) {
      T value = node.value;
      result = dg(value);
      node.value = value;

      if(result)
        break;
    }

    return result;
  }
}
