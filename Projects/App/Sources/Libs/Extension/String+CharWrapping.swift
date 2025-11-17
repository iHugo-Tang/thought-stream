extension String {
  
  /// Forces the string to apply the break by character mode.
  ///
  /// Text("This is a long text.".forceCharWrapping)
  var forceCharWrapping: Self {
    self.map({ String($0) }).joined(separator: "\u{200B}")
  }
}
