{
  description = "Flake templates by Brawl345";

  outputs = { self }: {
    templates = {
      simple = {
        path = ./simple;
        description = "Default blank template";
      };
      poetry = {
        path = ./poetry;
        description = "A Poetry project";
      };
    };

    defaultTemplate = self.templates.simple;
  };

}
