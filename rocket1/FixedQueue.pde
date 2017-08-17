class FixedQueue <T> {
  public final int capacity;
  private final ArrayList<T> queue; 
  private int current;

  public FixedQueue (int capacity, T def) {
    this.capacity = capacity;
    queue = new ArrayList<T> (capacity);
    for (int i = 0; i < capacity; i++) {
      queue.add(def);
    }
    current = 0;
  }

  public void push(T x) {
    queue.set(current, x);
    current = (current + 1) % capacity;
  }

  public T peek() {
    return queue.get(current);
  }
}