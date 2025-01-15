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

    class Character {
        id: int
        user_id: int
        name: string
        created_at: datetime
        updated_at: datetime
    }

    User --> Character : has_many
```
