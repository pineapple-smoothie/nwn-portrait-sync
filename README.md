# Neverwinter Nights Portrait Sync

This is a tool to sync character portraits for Neverwinter Nights (1) persistent
online servers, such as [Arelith](https://nwnarelith.com/).

## Usage

- Create an account
- Create your character
- Upload their portrait
- Download other characters' portraits

## Domain

```mermaid
classDiagram
    class User {
        id: int
        email_address: string
        password_digest: string
    }

    class Session {
        id: int
        user_id: int
        ip_address: string
        user_agent: string
        created_at: datetime
        updated_at: datetime
    }

    class Character {
        id: int
        user_id: int
        name: string
        created_at: datetime
        updated_at: datetime
    }

    class Portrait {
        id: int
        unique_name: string
        character_id: int
        image: attachment
        created_at: datetime
        updated_at: datetime
    }

    User --> Session : has_many
    User --> Character : has_many
    Character --> Portrait : has_many
```
