{
  description = "Flake templates by Brawl345";

  outputs = { self }: {
    templates = {
      simple = {
        path = ./simple;
        description = "Default blank template";
      };
    };

    defaultTemplate = self.templates.simple;
  };

}
