module prova.collision.spacialmap2d;

import prova.attachables;
import prova.collision;
import prova.core;
import prova.graphics;
import prova.math;
import prova.util;
import std.math;

///
class SpacialMap2D
{
  ///
  int bucketPadding = 5;
  private Vector2 bucketSize;
  private LinkedList!(Collider2D)[Vector2] map;
  private LinkedList!(Collider2D) colliders;
  private LinkedList!(Collider2D[2]) collisions;

  ///
  this()
  {
    colliders = new LinkedList!(Collider2D);
    collisions = new LinkedList!(Collider2D[2]);
  }

  ///
  void mapColliders()
  {
    foreach(Collider2D collider; colliders)
    {
      // we map the corners to a space,
      // edges don't matter as the buckets are
      // as big as the largest collider
      Rect bounds = collider.getBounds();

      mapColliderCorner(bounds.getTopLeft(), collider);
      mapColliderCorner(bounds.getTopRight(), collider);
      mapColliderCorner(bounds.getBottomLeft(), collider);
      mapColliderCorner(bounds.getBottomRight(), collider);

      collider.previousCollisions = collider.collisions;
      collider.collisions = new LinkedList!Collider2D;
    }
  }

  private void mapColliderCorner(Vector2 corner, Collider2D collider)
  {
    Vector2 key = Vector2(
      floor(corner.x / bucketSize.x),
      floor(corner.y / bucketSize.y)
    );

    if(!(key in map))
      map[key] = new LinkedList!(Collider2D);

    LinkedList!Collider2D bucket = map[key];

    if(!bucket.contains(collider))
      map[key].insertBack(collider);
  }

  ///
  void markCollisions()
  {
    // loop through buckets in the spacial map
    foreach(LinkedList!Collider2D bucket; map.values)
    {
      searchBucket(bucket);
      
      bucket.clear();
    }

    map.clear();
  }

  private void searchBucket(LinkedList!Collider2D bucket)
  {
    // test for collision with every collider within the bucket
    foreach(Node!Collider2D nodeA; bucket)
    {
      Collider2D colliderA = nodeA.value;

      // test with colliders that haven't already been tested with every collider
      // by starting after the current collider being tested
      for(Node!Collider2D nodeB = nodeA.getNext(); nodeB; nodeB = nodeB.getNext())
      {
        Collider2D colliderB = nodeB.value;

        if(colliderA.intersects(colliderB) && !colliderA.collisions.contains(colliderB))
          markCollision(colliderA, colliderB);
      }
    }
  }

  private void markCollision(Collider2D colliderA, Collider2D colliderB)
  {
    colliderA.collisions.insertBack(colliderB);
    colliderB.collisions.insertBack(colliderA);

    Collider2D[2] collision = [colliderA, colliderB];
    collisions.insertBack(collision);
  }

  ///
  void resolveCollisions()
  {
    foreach(Collider2D[2] collision; collisions)
      resolveCollision(collision[0], collision[1]);

    foreach(Collider2D colliderA; colliders)
      foreach(Collider2D colliderB; colliderA.previousCollisions)
        colliderA.entity.onCollisionExit2D(colliderA, colliderB);

    collisions.clear();
  }

  private void resolveCollision(Collider2D colliderA, Collider2D colliderB)
  {
    if(!colliderA.previousCollisions.contains(colliderB)) {
      colliderA.entity.onCollisionEnter2D(colliderA, colliderB);
      colliderB.entity.onCollisionEnter2D(colliderB, colliderA);
    }

    colliderA.entity.onCollision2D(colliderA, colliderB);
    colliderB.entity.onCollision2D(colliderB, colliderA);

    // remove the collision from the previous list if it exists,
    // to speed up the collision exit loop
    colliderA.previousCollisions.remove(colliderB);
    colliderB.previousCollisions.remove(colliderA);
  }

  /// Should not be called in most circumstances
  void add(Collider2D collider)
  {
    colliders.insertBack(collider);
    collider.spacialMap = this;

    updateBucketSize(collider);
  }

  /// Should not be called in most circumstances
  void add(LinkedList!Collider2D colliders)
  {
    foreach(Collider2D collider; colliders) {
      this.colliders.insertBack(collider);
      collider.spacialMap = this;

      updateBucketSize(collider);
    }
  }

  /// Should not be called in most circumstances
  void remove(Collider2D collider)
  {
    colliders.remove(collider);
    collider.spacialMap = null;

    updateBucketSize();
  }

  /// Should not be called in most circumstances
  void remove(LinkedList!Collider2D colliders)
  {
    foreach(Collider2D collider; colliders) {
      colliders.remove(collider);
      collider.spacialMap = null;
    }

    updateBucketSize();
  }

  private void updateBucketSize()
  {
    bucketSize.set(0, 0);

    foreach(Collider2D collider; colliders)
      updateBucketSize(collider);
  }

  package(prova) void updateBucketSize(Collider2D collider)
  {
    const Vector2 size = collider.getSize();

    if(size.x + bucketPadding * 2 > bucketSize.x)
      bucketSize.x = size.x + bucketPadding * 2;
    if(size.y + bucketPadding * 2 > bucketSize.y)
      bucketSize.y = size.y + bucketPadding * 2;
  }
}
