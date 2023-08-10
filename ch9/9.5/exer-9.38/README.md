# Solution

When `self` is used in class method, the whole class definition must be already known to properly type check, so it's necessary to add class information in static class environment in first pass, then in second pass we can type check class method properly.
