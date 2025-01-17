// RUN: %target-swift-emit-silgen                           \
// RUN:     %s                                              \
// RUN:     -enable-experimental-feature CoroutineAccessors \
// RUN: | %FileCheck %s --check-prefixes=CHECK,CHECK-NOUNWIND

// RUN: %target-swift-emit-silgen                                              \
// RUN:     %s                                                                 \
// RUN:     -enable-experimental-feature CoroutineAccessors                    \
// RUN:     -enable-experimental-feature CoroutineAccessorsUnwindOnCallerError \
// RUN: | %FileCheck %s --check-prefixes=CHECK,CHECK-UNWIND

// A read requirement may be satisfied by
// - a stored property
// - a _read accessor
// - a read accessor
// - a get accessor
// - an unsafeAddress accessor

struct U : ~Copyable {}

// Protocols are split up to improve the ordering of the functions in the output
// (implementation, then conformance thunk).
protocol P1 : ~Copyable {
  @_borrowed
  var ubgs: U { get set }
}
protocol P2 : ~Copyable {
  var urs: U { read set }
}
protocol P3 : ~Copyable {
  var ur: U { read }
}

struct ImplAStored : ~Copyable & P1 {
  var ubgs: U
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplAStoredV4ubgsAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[COPY_UNCHECKED:%[^,]+]] = copy_value [[SELF]]
// CHECK:         [[COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[COPY_UNCHECKED]]
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[COPY]]
// CHECK:         [[VALUE:%[^,]+]] = struct_extract [[BORROW]]
// CHECK-SAME:        #ImplAStored.ubgs
// CHECK:         yield [[VALUE]]
// CHECK-SAME:        resume [[SUCCESS:bb[0-9]+]]
// CHECK-SAME:        unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplAStoredV4ubgsAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplAStoredVAA2P1A2aDP4ubgsAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load_borrow [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements11ImplAStoredV4ubgsAA1UVvr
// CHECK:         ([[VALUE_ADDR:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE_ADDR]]
// CHECK-SAME:        resume [[SUCCESS:bb[0-9]+]]
// CHECK-SAME:        unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplAStoredVAA2P1A2aDP4ubgsAA1UVvrTW'
}

struct ImplBStored : ~Copyable & P2 {
  var dummy: ()
  var urs: U
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplBStoredV3ursAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[COPY_UNCHECKED:%[^,]+]] = copy_value [[SELF]]
// CHECK:         [[COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[COPY_UNCHECKED]]
// CHECK:         debug_value [[COPY]]
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[COPY]]
// CHECK:         [[VALUE:%[^,]+]] = struct_extract [[BORROW]]
// CHECK-SAME:        #ImplBStored.urs
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplBStoredV3ursAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplBStoredVAA2P2A2aDP3ursAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load_borrow [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements11ImplBStoredV3ursAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplBStoredVAA2P2A2aDP3ursAA1UVvrTW'
}

struct ImplCStored : ~Copyable & P3 {
  var dummy: ()
  var ur: U
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplCStoredV2urAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[COPY_UNCHECKED:%[^,]+]] = copy_value [[SELF]]
// CHECK:         [[COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[COPY_UNCHECKED]]
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[COPY]]
// CHECK:         [[VALUE:%[^,]+]] = struct_extract [[BORROW]]
// CHECK-SAME:        #ImplCStored.ur
// CHECK:         yield [[VALUE]]
// CHECK-SAME:        resume [[SUCCESS:bb[0-9]+]]
// CHECK-SAME:        unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplCStoredV2urAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplCStoredVAA2P3A2aDP2urAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load_borrow [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements11ImplCStoredV2urAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplCStoredVAA2P3A2aDP2urAA1UVvrTW'
}

struct ImplAUnderscoredCoroutineAccessors : ~Copyable & P1 {
  typealias Property = U
  var _i: U
  var ubgs: U {
    _read {
      yield _i
    }
    _modify {
      yield &_i
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements34ImplAUnderscoredCoroutineAccessorsV4ubgsAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[COPY_UNCHECKED:%[^,]+]] = copy_value [[SELF]]
// CHECK:         [[COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[COPY_UNCHECKED]]
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[COPY]]
// CHECK:         [[VALUE:%[^,]+]] = struct_extract [[BORROW]]
// CHECK:             #ImplAUnderscoredCoroutineAccessors._i
// CHECK:         yield [[VALUE]] : $U
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements34ImplAUnderscoredCoroutineAccessorsV4ubgsAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements34ImplAUnderscoredCoroutineAccessorsVAA2P1A2aDP4ubgsAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load_borrow [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements34ImplAUnderscoredCoroutineAccessorsV4ubgsAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements34ImplAUnderscoredCoroutineAccessorsVAA2P1A2aDP4ubgsAA1UVvrTW'
}

struct ImplBUnderscoredCoroutineAccessors : ~Copyable & P2 {
  typealias Property = U
  var _i: U
  var urs: U {
    _read {
      yield _i
    }
    _modify {
      yield &_i
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements34ImplBUnderscoredCoroutineAccessorsV3ursAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[COPY_UNCHECKED:%[^,]+]] = copy_value [[SELF]]
// CHECK:         [[COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[COPY_UNCHECKED]]
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[COPY]]
// CHECK:         [[VALUE:%[^,]+]] = struct_extract [[BORROW]]
// CHECK-SAME:        #ImplBUnderscoredCoroutineAccessors._i
// CHECK:         yield [[VALUE]]
// CHECK-SAME:        resume [[SUCCESS:bb[0-9]+]]
// CHECK-SAME:        unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements34ImplBUnderscoredCoroutineAccessorsV3ursAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements34ImplBUnderscoredCoroutineAccessorsVAA2P2A2aDP3ursAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load_borrow [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements34ImplBUnderscoredCoroutineAccessorsV3ursAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]] : $U
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements34ImplBUnderscoredCoroutineAccessorsVAA2P2A2aDP3ursAA1UVvrTW'
}

struct ImplCUnderscoredCoroutineAccessors : ~Copyable & P3 {
  typealias Property = U
  var _i: U
  var ur: U {
    _read {
      yield _i
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements34ImplCUnderscoredCoroutineAccessorsVAA2P3A2aDP2urAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]]
// CHECK:       ):
// CHECK:         [[SELF:%[^,]+]] = load_borrow [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements34ImplCUnderscoredCoroutineAccessorsV2urAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements34ImplCUnderscoredCoroutineAccessorsVAA2P3A2aDP2urAA1UVvrTW'
}

struct ImplACoroutineAccessors : ~Copyable & P1 {
  var _i: U
  var ubgs: U {
    read {
      yield _i
    }
    modify {
      yield &_i
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements23ImplACoroutineAccessorsV4ubgsAA1UVvy : {{.*}} {
// CHECK:       bb0(
// CHECK:           [[SELF:%[^:]+]]
// CHECK:       ):
// CHECK:         [[COPY_UNCHECKED:%[^,]+]] = copy_value [[SELF]]
// CHECK:         [[COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[COPY_UNCHECKED]]
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[COPY]]
// CHECK:         [[VALUE:%[^,]+]] = struct_extract [[BORROW]]
// CHECK:             #ImplACoroutineAccessors._i
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements23ImplACoroutineAccessorsV4ubgsAA1UVvy'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements23ImplACoroutineAccessorsV4ubgsAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[COPY_UNCHECKED:%[^,]+]] = copy_value [[SELF]]
// CHECK:         [[COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[COPY_UNCHECKED]]
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[COPY]]
// CHECK:         [[READ2ER:%[^,]+]] = function_ref @$s17read_requirements23ImplACoroutineAccessorsV4ubgsAA1UVvy
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]], [[ALLOCATION:%[^,]+]]) = begin_apply [[READ2ER]]([[BORROW]])
// CHECK:         [[VALUE_COPY_UNCHECKED:%[^,]+]] = copy_value [[VALUE]]
// CHECK:         [[VALUE_COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[VALUE_COPY_UNCHECKED]]
// CHECK:         [[VALUE_BORROW:%[^,]+]] = begin_borrow [[VALUE_COPY]]
// CHECK:         yield [[VALUE_BORROW]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[VALUE_BORROW]]
// CHECK:         destroy_value [[VALUE_COPY]]
// CHECK:         end_apply [[TOKEN]]
// CHECK:         dealloc_stack [[ALLOCATION]]
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[VALUE_BORROW]]
// CHECK:         destroy_value [[VALUE_COPY]]
// CHECK:         end_apply [[TOKEN]]
// CHECK:         dealloc_stack [[ALLOCATION]]
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements23ImplACoroutineAccessorsV4ubgsAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements23ImplACoroutineAccessorsVAA2P1A2aDP4ubgsAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load_borrow [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements23ImplACoroutineAccessorsV4ubgsAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK-SAME:        resume [[SUCCESS:bb[0-9]+]]
// CHECK-SAME:        unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements23ImplACoroutineAccessorsVAA2P1A2aDP4ubgsAA1UVvrTW'
}

struct ImplBCoroutineAccessors : ~Copyable & P2 {
  var _i: U
  var urs: U {
    read {
      yield _i
    }
    modify {
      yield &_i
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements23ImplBCoroutineAccessorsV3ursAA1UVvy : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[COPY_UNCHECKED:%[^,]+]] = copy_value [[SELF]]
// CHECK:         [[COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[COPY_UNCHECKED]]
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[COPY]]
// CHECK:         [[VALUE:%[^,]+]] = struct_extract [[BORROW]] : $ImplBCoroutineAccessors
// CHECK:             #ImplBCoroutineAccessors._i
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements23ImplBCoroutineAccessorsV3ursAA1UVvy'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements23ImplBCoroutineAccessorsV3ursAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[COPY_UNCHECKED:%[^,]+]] = copy_value [[SELF]]
// CHECK:         [[COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[COPY_UNCHECKED]]
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[COPY]]
// CHECK:         [[READ2ER:%[^,]+]] = function_ref @$s17read_requirements23ImplBCoroutineAccessorsV3ursAA1UVvy
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]], [[ALLOCATION:%[^,]+]]) = begin_apply [[READ2ER]]([[BORROW]])
// CHECK:         [[VALUE_COPY_UNCHECKED:%[^,]+]] = copy_value [[VALUE]]
// CHECK:         [[VALUE_COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[VALUE_COPY_UNCHECKED]]
// CHECK:         [[VALUE_BORROW:%[^,]+]] = begin_borrow [[VALUE_COPY]]
// CHECK:         yield [[VALUE_BORROW]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[VALUE_BORROW]]
// CHECK:         destroy_value [[VALUE_COPY]]
// CHECK:         end_apply [[TOKEN]]
// CHECK:         dealloc_stack [[ALLOCATION]]
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[VALUE_BORROW]]
// CHECK:         destroy_value [[VALUE_COPY]]
// CHECK:         end_apply [[TOKEN]]
// CHECK:         dealloc_stack [[ALLOCATION]]
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements23ImplBCoroutineAccessorsV3ursAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements23ImplBCoroutineAccessorsVAA2P2A2aDP3ursAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load_borrow [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements23ImplBCoroutineAccessorsV3ursAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]] : $ImplBCoroutineAccessors
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]] : $ImplBCoroutineAccessors
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements23ImplBCoroutineAccessorsVAA2P2A2aDP3ursAA1UVvrTW'
}

struct ImplCCoroutineAccessors : ~Copyable & P3 {
  var _i: U
  var ur: U {
    read {
      yield _i
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements23ImplCCoroutineAccessorsV2urAA1UVvy : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[COPY_UNCHECKED:%[^,]+]] = copy_value [[SELF]]
// CHECK:         [[COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[COPY_UNCHECKED]]
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[COPY]]
// CHECK:         [[VALUE:%[^,]+]] = struct_extract [[BORROW]]
// CHECK-SAME:        #ImplCCoroutineAccessors._i
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements23ImplCCoroutineAccessorsV2urAA1UVvy'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements23ImplCCoroutineAccessorsV2urAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[COPY_UNCHECKED:%[^,]+]] = copy_value [[SELF:%[^,]+]]
// CHECK:         [[COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[COPY_UNCHECKED]]
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[COPY]]
// CHECK:         [[READ2ER:%[^,]+]] = function_ref @$s17read_requirements23ImplCCoroutineAccessorsV2urAA1UVvy
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]], [[ALLOCATION:%[^,]+]]) = begin_apply [[READ2ER]]([[BORROW]])
// CHECK:         [[VALUE_COPY_UNCHECKED:%[^,]+]] = copy_value [[VALUE:%[^,]+]]
// CHECK:         [[VALUE_COPY:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[VALUE_COPY_UNCHECKED]]
// CHECK:         [[VALUE_BORROW:%[^,]+]] = begin_borrow [[VALUE_COPY]]
// CHECK:         yield [[VALUE_BORROW]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[VALUE_BORROW]]
// CHECK:         destroy_value [[VALUE_COPY]]
// CHECK:         end_apply [[TOKEN]]
// CHECK:         dealloc_stack [[ALLOCATION]]
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[VALUE_BORROW]]
// CHECK:         destroy_value [[VALUE_COPY]]
// CHECK:         end_apply [[TOKEN]]
// CHECK:         dealloc_stack [[ALLOCATION]]
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[COPY]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements23ImplCCoroutineAccessorsV2urAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements23ImplCCoroutineAccessorsVAA2P3A2aDP2urAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]]
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load_borrow [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements23ImplCCoroutineAccessorsV2urAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK-SAME:        resume [[SUCCESS:bb[0-9]+]]
// CHECK-SAME:        unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         end_borrow [[SELF]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements23ImplCCoroutineAccessorsVAA2P3A2aDP2urAA1UVvrTW'
}

struct ImplAGetSet : P1 {
  var _i: U {
    get { return U() }
    set {}
  }
  var ubgs: U {
    get {
      return _i
    }
    set {
      _i = newValue
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplAGetSetV4ubgsAA1UVvg : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[_I_GETTER:%[^,]+]] = function_ref @$s17read_requirements11ImplAGetSetV2_iAA1UVvg
// CHECK:         [[VALUE:%[^,]+]] = apply [[_I_GETTER]]([[SELF]])
// CHECK:         return [[VALUE]]
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplAGetSetV4ubgsAA1UVvg'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplAGetSetV4ubgsAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[GETTER:%[^,]+]] = function_ref @$s17read_requirements11ImplAGetSetV4ubgsAA1UVvg
// CHECK:         [[VALUE:%[^,]+]] = apply [[GETTER]]([[SELF]])
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[VALUE]]
// CHECK:         yield [[BORROW]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[VALUE]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[VALUE]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplAGetSetV4ubgsAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplAGetSetVAA2P1A2aDP4ubgsAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR]]
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load [trivial] [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements11ImplAGetSetV4ubgsAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplAGetSetVAA2P1A2aDP4ubgsAA1UVvrTW'
}

struct ImplBGetSet : P2 {
  var _i: U {
    get { return U() }
    set {}
  }
  var urs: U {
    get {
      return _i
    }
    set {
      _i = newValue
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplBGetSetV3ursAA1UVvg : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[_I_GETTER:%[^,]+]] = function_ref @$s17read_requirements11ImplBGetSetV2_iAA1UVvg
// CHECK:         [[VALUE:%[^,]+]] = apply [[_I_GETTER]]([[SELF]])
// CHECK:         return [[VALUE]]
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplBGetSetV3ursAA1UVvg'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplBGetSetV3ursAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[GETTER:%[^,]+]] = function_ref @$s17read_requirements11ImplBGetSetV3ursAA1UVvg
// CHECK:         [[VALUE:%[^,]+]] = apply [[GETTER]]([[SELF]])
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[VALUE]]
// CHECK:         yield [[BORROW]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[VALUE]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[VALUE]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplBGetSetV3ursAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplBGetSetVAA2P2A2aDP3ursAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load [trivial] [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements11ImplBGetSetV3ursAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplBGetSetVAA2P2A2aDP3ursAA1UVvrTW'
}

struct ImplCGetSet : P3 {
  var _i: U {
    get { return U() }
    set {}
  }
  var ur: U {
    get {
      return _i
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplCGetSetV2urAA1UVvg : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[_I_GETTER:%[^,]+]] = function_ref @$s17read_requirements11ImplCGetSetV2_iAA1UVvg
// CHECK:         [[VALUE:%[^,]+]] = apply [[_I_GETTER]]([[SELF]])
// CHECK:         return [[VALUE]]
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplCGetSetV2urAA1UVvg'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplCGetSetV2urAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[GETTER:%[^,]+]] = function_ref @$s17read_requirements11ImplCGetSetV2urAA1UVvg
// CHECK:         [[VALUE:%[^,]+]] = apply [[GETTER]]([[SELF]])
// CHECK:         [[BORROW:%[^,]+]] = begin_borrow [[VALUE]]
// CHECK:         yield [[BORROW]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[VALUE]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         end_borrow [[BORROW]]
// CHECK:         destroy_value [[VALUE]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplCGetSetV2urAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements11ImplCGetSetVAA2P3A2aDP2urAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load [trivial] [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements11ImplCGetSetV2urAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements11ImplCGetSetVAA2P3A2aDP2urAA1UVvrTW'
}

struct ImplAUnsafeAddressors : P1 {
  var iAddr: UnsafePointer<U>
  var iMutableAddr: UnsafeMutablePointer<U> {
    .init(mutating: iAddr)
  }
  var ubgs: U {
    unsafeAddress {
      return iAddr
    }
    unsafeMutableAddress {
      return iMutableAddr
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements21ImplAUnsafeAddressorsV4ubgsAA1UVvlu : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[UNSAFE_POINTER:%[^,]+]] = struct_extract [[SELF]] : $ImplAUnsafeAddressors
// CHECK:             #ImplAUnsafeAddressors.iAddr
// CHECK:         return [[UNSAFE_POINTER]]
// CHECK-LABEL: } // end sil function '$s17read_requirements21ImplAUnsafeAddressorsV4ubgsAA1UVvlu'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements21ImplAUnsafeAddressorsV4ubgsAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[UNSAFE_ADDRESSOR:%[^,]+]] = function_ref @$s17read_requirements21ImplAUnsafeAddressorsV4ubgsAA1UVvlu
// CHECK:         [[UNSAFE_POINTER:%[^,]+]] = apply [[UNSAFE_ADDRESSOR]]([[SELF]])
// CHECK:         [[RAW_POINTER:%[^,]+]] = struct_extract [[UNSAFE_POINTER]] : $UnsafePointer<U>, #UnsafePointer._rawValue
// CHECK:         [[ADDR:%[^,]+]] = pointer_to_address [[RAW_POINTER]]
// CHECK:         [[ACCESS_UNCHECKED:%[^,]+]] = begin_access [read] [unsafe] [[ADDR]]
// CHECK:         [[ACCESS:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[ACCESS_UNCHECKED]]
// CHECK:         [[VALUE:%[^,]+]] = load [copy] [[ACCESS]]
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         destroy_value [[VALUE]]
// CHECK:         end_access [[ACCESS_UNCHECKED]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         destroy_value [[VALUE]]
// CHECK:         end_access [[ACCESS_UNCHECKED]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements21ImplAUnsafeAddressorsV4ubgsAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements21ImplAUnsafeAddressorsVAA2P1A2aDP4ubgsAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR]]
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load [trivial] [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements21ImplAUnsafeAddressorsV4ubgsAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements21ImplAUnsafeAddressorsVAA2P1A2aDP4ubgsAA1UVvrTW'
}

struct ImplBUnsafeAddressors : P2 {
  var iAddr: UnsafePointer<U>
  var iMutableAddr: UnsafeMutablePointer<U> {
    .init(mutating: iAddr)
  }
  var urs: U {
    unsafeAddress {
      return iAddr
    }
    unsafeMutableAddress {
      return iMutableAddr
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements21ImplBUnsafeAddressorsV3ursAA1UVvlu : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[UNSAFE_POINTER:%[^,]+]] = struct_extract [[SELF]]
// CHECK:             #ImplBUnsafeAddressors.iAddr
// CHECK:         return [[UNSAFE_POINTER]]
// CHECK-LABEL: } // end sil function '$s17read_requirements21ImplBUnsafeAddressorsV3ursAA1UVvlu'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements21ImplBUnsafeAddressorsV3ursAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[UNSAFE_ADDRESSOR:%[^,]+]] = function_ref @$s17read_requirements21ImplBUnsafeAddressorsV3ursAA1UVvlu
// CHECK:         [[UNSAFE_POINTER:%[^,]+]] = apply [[UNSAFE_ADDRESSOR]]([[SELF]])
// CHECK:         [[RAW_POINTER:%[^,]+]] = struct_extract [[UNSAFE_POINTER]]
// CHECK:             #UnsafePointer._rawValue
// CHECK:         [[ADDR:%[^,]+]] = pointer_to_address [[RAW_POINTER]]
// CHECK:         [[ACCESS_UNCHECKED:%[^,]+]] = begin_access [read] [unsafe] [[ADDR]]
// CHECK:         [[ACCESS:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[ACCESS_UNCHECKED]]
// CHECK:         [[VALUE:%[^,]+]] = load [copy] [[ACCESS]]
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         destroy_value [[VALUE]]
// CHECK:         end_access [[ACCESS_UNCHECKED]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         destroy_value [[VALUE]]
// CHECK:         end_access [[ACCESS_UNCHECKED]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements21ImplBUnsafeAddressorsV3ursAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements21ImplBUnsafeAddressorsVAA2P2A2aDP3ursAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load [trivial] [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements21ImplBUnsafeAddressorsV3ursAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements21ImplBUnsafeAddressorsVAA2P2A2aDP3ursAA1UVvrTW'
}

struct ImplCUnsafeAddressors : P3 {
  var iAddr: UnsafePointer<U>
  var iMutableAddr: UnsafeMutablePointer<U> {
    .init(mutating: iAddr)
  }
  var ur: U {
    unsafeAddress {
      return iAddr
    }
    unsafeMutableAddress {
      return iMutableAddr
    }
  }
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements21ImplCUnsafeAddressorsV2urAA1UVvlu : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[UNSAFE_POINTER:%[^,]+]] = struct_extract [[SELF]]
// CHECK:             #ImplCUnsafeAddressors.iAddr 
// CHECK:         return [[UNSAFE_POINTER]]
// CHECK-LABEL: } // end sil function '$s17read_requirements21ImplCUnsafeAddressorsV2urAA1UVvlu'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements21ImplCUnsafeAddressorsV2urAA1UVvr : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[UNSAFE_ADDRESSOR:%[^,]+]] = function_ref @$s17read_requirements21ImplCUnsafeAddressorsV2urAA1UVvlu
// CHECK:         [[UNSAFE_POINTER:%[^,]+]] = apply [[UNSAFE_ADDRESSOR]]([[SELF]])
// CHECK:         [[RAW_POINTER:%[^,]+]] = struct_extract [[UNSAFE_POINTER]]
// CHECK:             #UnsafePointer._rawValue
// CHECK:         [[ADDR:%[^,]+]] = pointer_to_address [[RAW_POINTER]]
// CHECK:         [[ACCESS_UNCHECKED:%[^,]+]] = begin_access [read] [unsafe] [[ADDR]]
// CHECK:         [[ACCESS:%[^,]+]] = mark_unresolved_non_copyable_value [no_consume_or_assign] [[ACCESS_UNCHECKED]]
// CHECK:         [[VALUE:%[^,]+]] = load [copy] [[ACCESS]]
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         destroy_value [[VALUE]]
// CHECK:         end_access [[ACCESS_UNCHECKED]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         destroy_value [[VALUE]]
// CHECK:         end_access [[ACCESS_UNCHECKED]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements21ImplCUnsafeAddressorsV2urAA1UVvr'
// CHECK-LABEL: sil{{.*}} [ossa] @$s17read_requirements21ImplCUnsafeAddressorsVAA2P3A2aDP2urAA1UVvrTW : {{.*}} {
// CHECK:       bb0(
// CHECK-SAME:      [[SELF_ADDR:%[^:]+]] :
// CHECK-SAME:  ):
// CHECK:         [[SELF:%[^,]+]] = load [trivial] [[SELF_ADDR]]
// CHECK:         [[READER:%[^,]+]] = function_ref @$s17read_requirements21ImplCUnsafeAddressorsV2urAA1UVvr
// CHECK:         ([[VALUE:%[^,]+]], [[TOKEN:%[^,]+]]) = begin_apply [[READER]]([[SELF]])
// CHECK:         yield [[VALUE]]
// CHECK:             resume [[SUCCESS:bb[0-9]+]]
// CHECK:             unwind [[FAILURE:bb[0-9]+]]
// CHECK:       [[SUCCESS]]:
// CHECK:         end_apply [[TOKEN]]
// CHECK:         return
// CHECK:       [[FAILURE]]:
// CHECK:         abort_apply [[TOKEN]]
// CHECK:         unwind
// CHECK-LABEL: } // end sil function '$s17read_requirements21ImplCUnsafeAddressorsVAA2P3A2aDP2urAA1UVvrTW'
}
// CHECK-LABEL: sil_witness_table{{.*}} ImplAStored: P1 module read_requirements {
// CHECK:         method #P1.ubgs!read
// CHECK-SAME:      : @$s17read_requirements11ImplAStoredVAA2P1A2aDP4ubgsAA1UVvrTW
// CHECK:         method #P1.ubgs!setter
// CHECK-SAME:      : @$s17read_requirements11ImplAStoredVAA2P1A2aDP4ubgsAA1UVvsTW
// CHECK:         method #P1.ubgs!modify
// CHECK-SAME:      : @$s17read_requirements11ImplAStoredVAA2P1A2aDP4ubgsAA1UVvMTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplBStored: P2 module read_requirements {
// CHECK:         method #P2.urs!read
// CHECK-SAME:        : @$s17read_requirements11ImplBStoredVAA2P2A2aDP3ursAA1UVvrTW
// CHECK:         method #P2.urs!setter
// CHECK-SAME:        : @$s17read_requirements11ImplBStoredVAA2P2A2aDP3ursAA1UVvsTW
// CHECK:         method #P2.urs!modify
// CHECK-SAME:        : @$s17read_requirements11ImplBStoredVAA2P2A2aDP3ursAA1UVvMTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplCStored: P3 module read_requirements {
// CHECK:         method #P3.ur!read
// CHECK-SAME:        : @$s17read_requirements11ImplCStoredVAA2P3A2aDP2urAA1UVvrTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplAUnderscoredCoroutineAccessors: P1 module read_requirements {
// CHECK:         method #P1.ubgs!read
// CHECK-SAME:        : @$s17read_requirements34ImplAUnderscoredCoroutineAccessorsVAA2P1A2aDP4ubgsAA1UVvrTW
// CHECK:         method #P1.ubgs!setter
// CHECK-SAME:        : @$s17read_requirements34ImplAUnderscoredCoroutineAccessorsVAA2P1A2aDP4ubgsAA1UVvsTW
// CHECK:         method #P1.ubgs!modify
// CHECK-SAME:        : @$s17read_requirements34ImplAUnderscoredCoroutineAccessorsVAA2P1A2aDP4ubgsAA1UVvMTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplBUnderscoredCoroutineAccessors: P2 module read_requirements {
// CHECK:         method #P2.urs!read
// CHECK-SAME:        : @$s17read_requirements34ImplBUnderscoredCoroutineAccessorsVAA2P2A2aDP3ursAA1UVvrTW
// CHECK:         method #P2.urs!setter
// CHECK-SAME:        : @$s17read_requirements34ImplBUnderscoredCoroutineAccessorsVAA2P2A2aDP3ursAA1UVvsTW
// CHECK:         method #P2.urs!modify
// CHECK-SAME:        : @$s17read_requirements34ImplBUnderscoredCoroutineAccessorsVAA2P2A2aDP3ursAA1UVvMTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplCUnderscoredCoroutineAccessors: P3 module read_requirements {
// CHECK:         method #P3.ur!read
// CHECK-SAME:        : @$s17read_requirements34ImplCUnderscoredCoroutineAccessorsVAA2P3A2aDP2urAA1UVvrTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplACoroutineAccessors: P1 module read_requirements {
// CHECK:         method #P1.ubgs!read
// CHECK-SAME:        : @$s17read_requirements23ImplACoroutineAccessorsVAA2P1A2aDP4ubgsAA1UVvrTW
// CHECK:         method #P1.ubgs!setter
// CHECK-SAME:        : @$s17read_requirements23ImplACoroutineAccessorsVAA2P1A2aDP4ubgsAA1UVvsTW
// CHECK:         method #P1.ubgs!modify
// CHECK-SAME:        : @$s17read_requirements23ImplACoroutineAccessorsVAA2P1A2aDP4ubgsAA1UVvMTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplBCoroutineAccessors: P2 module read_requirements {
// CHECK:         method #P2.urs!read
// CHECK-SAME:        : @$s17read_requirements23ImplBCoroutineAccessorsVAA2P2A2aDP3ursAA1UVvrTW
// CHECK:         method #P2.urs!setter
// CHECK-SAME:        : @$s17read_requirements23ImplBCoroutineAccessorsVAA2P2A2aDP3ursAA1UVvsTW
// CHECK:         method #P2.urs!modify
// CHECK-SAME:        : @$s17read_requirements23ImplBCoroutineAccessorsVAA2P2A2aDP3ursAA1UVvMTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplCCoroutineAccessors: P3 module read_requirements {
// CHECK:         method #P3.ur!read
// CHECK-SAME:        : @$s17read_requirements23ImplCCoroutineAccessorsVAA2P3A2aDP2urAA1UVvrTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplAGetSet: P1 module read_requirements {
// CHECK:         method #P1.ubgs!read
// CHECK-SAME:        : @$s17read_requirements11ImplAGetSetVAA2P1A2aDP4ubgsAA1UVvrTW
// CHECK:         method #P1.ubgs!setter
// CHECK-SAME:        : @$s17read_requirements11ImplAGetSetVAA2P1A2aDP4ubgsAA1UVvsTW
// CHECK:         method #P1.ubgs!modify
// CHECK-SAME:        : @$s17read_requirements11ImplAGetSetVAA2P1A2aDP4ubgsAA1UVvMTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplBGetSet: P2 module read_requirements {
// CHECK:         method #P2.urs!read
// CHECK-SAME:        : @$s17read_requirements11ImplBGetSetVAA2P2A2aDP3ursAA1UVvrTW
// CHECK:         method #P2.urs!setter
// CHECK-SAME:        : @$s17read_requirements11ImplBGetSetVAA2P2A2aDP3ursAA1UVvsTW
// CHECK:         method #P2.urs!modify
// CHECK-SAME:        : @$s17read_requirements11ImplBGetSetVAA2P2A2aDP3ursAA1UVvMTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplCGetSet: P3 module read_requirements {
// CHECK:         method #P3.ur!read
// CHECK-SAME:        : @$s17read_requirements11ImplCGetSetVAA2P3A2aDP2urAA1UVvrTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplAUnsafeAddressors: P1 module read_requirements {
// CHECK:         method #P1.ubgs!read
// CHECK-SAME:        : @$s17read_requirements21ImplAUnsafeAddressorsVAA2P1A2aDP4ubgsAA1UVvrTW
// CHECK:         method #P1.ubgs!setter
// CHECK-SAME:        : @$s17read_requirements21ImplAUnsafeAddressorsVAA2P1A2aDP4ubgsAA1UVvsTW
// CHECK:         method #P1.ubgs!modify
// CHECK-SAME:        : @$s17read_requirements21ImplAUnsafeAddressorsVAA2P1A2aDP4ubgsAA1UVvMTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplBUnsafeAddressors: P2 module read_requirements {
// CHECK:         method #P2.urs!read
// CHECK-SAME:        : @$s17read_requirements21ImplBUnsafeAddressorsVAA2P2A2aDP3ursAA1UVvrTW
// CHECK:         method #P2.urs!setter
// CHECK-SAME:        : @$s17read_requirements21ImplBUnsafeAddressorsVAA2P2A2aDP3ursAA1UVvsTW
// CHECK:         method #P2.urs!modify
// CHECK-SAME:        : @$s17read_requirements21ImplBUnsafeAddressorsVAA2P2A2aDP3ursAA1UVvMTW
// CHECK:       }

// CHECK-LABEL: sil_witness_table{{.*}} ImplCUnsafeAddressors: P3 module read_requirements {
// CHECK:         method #P3.ur!read
// CHECK-SAME:        : @$s17read_requirements21ImplCUnsafeAddressorsVAA2P3A2aDP2urAA1UVvrTW
// CHECK:       }
