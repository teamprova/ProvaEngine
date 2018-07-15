module prova.util.linkedlist;

import std.typecons;
import std.exception;

/**
 * Linked list node
 */
class Node(T)
{
  private LinkedList!T list;
  private Node!T next;
  private Node!T last;
  private Nullable!T _value;

  private this(LinkedList!T list, T value) {
    this.list = list;
    this.value = value;
  }

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
    auto node = new Node!T(this, value);

    if(first) {
      first.last = node;
      node.next = first;
      first = node;
    } else {
      first = last = node;
    }

    return node;
  }

  /**
   * Creates a node and places it at the end of the list
   */
  Node!T insertBack(T value)
  {
    auto node = new Node!T(this, value);

    if(last) {
      last.next = node;
      node.last = last;
      last = node;
    } else {
      first = last = node;
    }

    return node;
  }

  /**
   * Creates a node in the list placed before the reference node
   */
  Node!T insertBefore(T value, Node!T referenceNode)
  {
    if(!referenceNode)
      return insertFront(value);

    auto node = new Node!T(this, value);

    if(referenceNode.list != this)
      throw new Exception("Reference node does not belong to this list");

    node.next = referenceNode;
    node.last = referenceNode.last;

    if(referenceNode.last)
      referenceNode.last.next = node;

    referenceNode.last = node;

    count++;
    return node;
  }

  /**
   * Creates a node in the list placed after the reference node
   */
  Node!T insertAfter(T value, Node!T referenceNode)
  {
    if(!referenceNode)
      return insertBack(value);

    if(referenceNode.list != this)
      throw new Exception("Reference node does not belong to this list");

    auto node = new Node!T(this, value);

    node.last = referenceNode;
    node.next = referenceNode.next;

    if(referenceNode.next)
      referenceNode.next.last = node;

    referenceNode.next = node;

    count++;
    return node;
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

  ///
  T[] toArray()
  {
    T[] array;
    array.reserve(length);

    foreach(T value; this) {
      array ~= value;
    }

    return array;
  }

  ///
  LinkedListRange!T toRange()
  {
    return LinkedListRange!T(this);
  }

  ///
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

  ///
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

///
struct LinkedListRange(T)
{
  Node!T node;

  private this(LinkedList!T list)
  {
    this.node = list.getFirstNode();
  }

  ///
  T front()
  {
    return node.value;
  }

  ///
  void popFront()
  {
    node = node.getNext();
  }

  ///
  bool empty()
  {
    return node is null;
  }
}
