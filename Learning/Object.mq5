// Define a class
class MyObject {
private:
  int m_value;
  string m_name;

public:
  // Constructor with parameters
  MyObject(int value, string name) {
    m_value = value;
    m_name = name;
  }

  // Getter for value
  int GetValue() { return m_value; }

  // Setter for value
  void SetValue(int value) { m_value = value; }

  // Getter for name
  string GetName() { return m_name; }
};

// Usage
void OnStart() {
  // Create an array of MyObject pointers
  MyObject *arr[3];

  // Initialize objects and store pointers in the array
  arr[0] = new MyObject(1, "Object 1");
  arr[1] = new MyObject(2, "Object 2");
  arr[2] = new MyObject(3, "Object 3");

  // Access and print values from the objects in the array
  for (int i = 0; i < 3; i++) {
    Print("Name: ", arr[i].GetName(), ", Value: ", arr[i].GetValue());
  }

  // Free the objects from memory
  for (int i = 0; i < 3; i++) {
    delete arr[i];
  }
}
