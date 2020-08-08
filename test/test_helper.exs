Mix.Task.run "ecto.drop", ["quiet", "-r", "Doumi.TestRepo"]
Mix.Task.run "ecto.create", ["quiet", "-r", "Doumi.TestRepo"]
Mix.Task.run "ecto.migrate", ["-r", "Doumi.TestRepo"]

Doumi.TestRepo.start_link()

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Doumi.TestRepo, :manual)
