# >> Frontend
## 1. Use via decorator
### 1.1 Define 2 functions
- evict_objects() - update, delete

args: 

a. only pass schema name, must be the same as `__struct__`.

b. wrapped function only support one arg, like keyword, map or value.

### 1.2 Ensuring cache consistency
### 1.3 Formatter
- only accept/return `{:ok, struct}` or `{:ok, nil}`.
### Notice
- required `id` & `__meta__`  & `__struct__` keys with every map.
- update, delete actions should delete themselves and related schemas.
- get, create actions store object.  
- suggest user store full object.

# >> Hooks
- pre_hook
- post_hook

### Functionalities
- TTL, second precision
### Data Structure
```elixir
%{
  db: %{
    User => [
      {%{
        __struct__: User,
        id: 1,
        name: "ljy",
        role: %{__struct__: Role, id: 11, name: "sys"},
        houses: [%{__struct__: House, id: 22, name: "szns"}]
      }, 1_623_400_777}
    ],
    Cargo => [
      {%{__struct__: Cargo, id: 2, name: "toy"}, 1_623_400_888},
      {%{__struct__: Cargo, id: 3, name: "pecil"}, 1_623_400_999}
    ]
  },
  meta: %{
    back_refs: %{
      Role => #MapSet<[User, Institution]>,
      House => #MapSet<[User]>
    }
    ids: %{
      User => [1, 2, 3],
      Cargo => [4, 5, 6]
    },
    capacity: %{
      User => 1,
      Cargo => 2
    },
    len: %{
      User => 1,
      Cargo => 2
    },
    tables: #MapSet<[User, Role]>,
    gc: %{
      counts: %{1_623_400_888 => 12}, 
      shards: %{
        1_623_400_888 => %{
          User => #MapSet<[1,2,3,4]>,
          Role => #MapSet<[5,6,7,8]>
        }
      }
    }
  }
}
```
### Ecto Schema Meta
```elixir
%{
  __struct__: Ecto.Schema.Metadata,
  context: nil,
  prefix: nil,
  schema: User,
  source: "user"
  state: :loaded
}
```


### config: only_test
