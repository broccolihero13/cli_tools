<Form color="#000000">
  <Section id="section1" display="false">
    <Computed
      id="siteDetails"
      label="SITE DETAILS"
      columns={3}
      formula="site ? locations[site] : false"
    />
    <Computed
      id="notmatched"
      label="Site Full Name"
      columns={3}
      formula="siteDetails ? siteDetails.siteFullName : ''"
    />
    <Tile
      id="tile1"
      label="Site Full Name"
      columns={3}
    />
    <Computed
      id="secretaryAssigned"
      label="ROUTING:Secretary"
      columns={3}
      display="false"
      formula="siteDetails && siteDetails.routeSecretaryAsstEmail ? { name: siteDetails.routeSecretaryAsstName , email: siteDetails.routeSecretaryAsstEmail } : false"
    />
    <Computed
      id="principalAssigned"
      label="ROUTING:Principal"
      columns={3}
      display="false"
      formula="siteDetails && siteDetails.routePrincipalDirectorEmail ? { name: siteDetails.routePrincipalDirectorName , email: siteDetails.routePrincipalDirectorEmail } : false"
    />
  </Section>
</Form>