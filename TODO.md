## 1. pre check
- only pass schema name, must be the same as `__struct__`.
- wrapped function first arg should be keyword, map or value.
- only accept/return `{:ok, struct}` or `{:ok, nil}`.
## 2. hooks
- pre_hook
- post_hook
## 3. Functionalities
- TTL, second precision.
- provide esc_drop, esc_truncate functions.
## 4. Data Structure
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
