Testing := Object clone
Testing assertTrue := method(arg, 
	argCalled := call message argAt(0);
	(arg) ifFalse(Exception raise("Expected to be true: " .. argCalled)))

Testing assertFalse := method(arg, 
	argCalled := call message argAt(0);
	(arg) ifTrue(Exception raise("Expected to be false: " .. argCalled)))

Testing assertEqual := method(arg1, arg2,
	expected := call message argAt(0);
	actual := call message argAt(1);
	(arg1 == arg2) ifFalse(Exception raise(actual .. " expected to be " .. expected .. " but was " .. arg2)))
